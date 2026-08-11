-- opencode 浮窗终端子系统：open/toggle/stop（纯 nvim API，零依赖）
--
-- 背景：opencode.nvim v0.14.0（commit a7c4dd7 "feat(server)!: drop stop and toggle"）
-- 移除了内置终端管理器（opencode.terminal）、server.stop/server.toggle 配置项和公开的
-- toggle()/stop() API，默认 server.start 改为原生 `vsplit term://opencode --port`。
-- 本模块用纯 nvim API 复活同等语义（与原实现行为一致）：
--   open()   打开浮窗（buffer 存活时直接显示）
--   toggle() 显示/隐藏浮窗，job 保留（快速切换）
--   stop()   终止 job + 关闭窗口 + 删除 buffer（幂等）
-- 清理策略：进程组 SIGTERM。Neovim 对终端 job 默认发 SIGHUP，opencode 收到 SIGHUP 会自重启。
local M = {}

M.cmd = "opencode"

local winid
local bufnr

---浮窗默认几何：85% 宽高、居中、圆角边框
local function default_float_opts()
  local w = math.floor(vim.o.columns * 0.85)
  local h = math.floor(vim.o.lines * 0.85)
  return {
    relative = "editor",
    width = w,
    height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = "minimal",
    border = "rounded",
  }
end

---进程组 SIGTERM：负 PID 终止整个进程组（opencode 会派生子进程，某些 shell 也会多一层）。
---原实现注释：SIGHUP 会让 opencode 自重启，SIGTERM 才能真正停掉。
local function terminate(pid)
  if vim.fn.has("unix") == 1 then
    os.execute("kill -TERM -" .. pid .. " 2>/dev/null")
  else
    pcall(vim.uv.kill, pid, "SIGTERM")
  end
end

---TermOpen 时缓存 PID（TermClose 时 terminal_job_id 已被清空，取不到），
---TermClose / VimLeavePre 时 SIGTERM 整个进程组，避免 opencode 进程残留。
local function setup_cleanup(buf)
  local pid
  vim.api.nvim_create_autocmd("TermOpen", {
    buffer = buf,
    once = true,
    callback = function(event)
      local job_id = vim.b[event.buf].terminal_job_id
      if job_id then
        local ok, p = pcall(vim.fn.jobpid, job_id)
        if ok then pid = p end
      end
    end,
  })
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buf,
    once = true,
    callback = function()
      if pid then
        terminate(pid)
      end
      bufnr = nil
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    once = true,
    callback = function()
      if pid then
        terminate(pid)
      end
    end,
  })
end

---打开 opencode 浮窗终端；buffer 存活时直接显示（不新建）。
---@param cmd? string 终端命令，默认 "opencode"
---@param opts? table vim.api.keyset.win_config，默认 85% 居中浮窗
---@return integer winid
function M.open(cmd, opts)
  if bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr) then
    winid = vim.api.nvim_open_win(bufnr, false, opts or default_float_opts())
    return winid
  end

  opts = opts or default_float_opts()
  bufnr = vim.api.nvim_create_buf(false, false)
  setup_cleanup(bufnr)
  winid = vim.api.nvim_open_win(bufnr, false, opts)
  vim.api.nvim_buf_call(bufnr, function()
    vim.fn.termopen(cmd or M.cmd, {
      on_exit = function()
        M.close()
      end,
    })
  end)
  return winid
end

---显示/隐藏浮窗（job 保留）。
function M.toggle(cmd, opts)
  if winid ~= nil and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_win_hide(winid)
    winid = nil
  elseif bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr) then
    winid = vim.api.nvim_open_win(bufnr, false, opts or default_float_opts())
  else
    M.open(cmd, opts)
  end
end

---浮窗当前是否可见
function M.is_visible()
  return winid ~= nil and vim.api.nvim_win_is_valid(winid)
end

---终止 job + 关闭窗口 + 删除 buffer（幂等）。
function M.stop()
  local job_id = bufnr and vim.b[bufnr] and vim.b[bufnr].terminal_job_id
  if job_id then
    pcall(vim.fn.jobstop, job_id)
  end
  if winid ~= nil and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_win_close(winid, true)
    winid = nil
  end
  if bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
    bufnr = nil
  end
end

M.close = M.stop

return M
