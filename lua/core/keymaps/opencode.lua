-- opencode 终端子系统:浮窗 toggle、聚焦、t 模式转义、选区提取、@file 选择
-- 与普通快捷键分离：这是一个独立的功能子系统（AI 终端生命周期管理）。
-- 键位：<Leader>co / <Leader>aa / <Leader>cO / <Leader><Esc> / t:<F11> <F12> / <C-w>p
-- 注意：opencode.nvim v0.14.0 已移除内置终端管理器和 toggle()/stop() API，
-- 浮窗生命周期由 core.keymaps.opencode_term（纯 nvim API）负责，与插件解耦。
local map = require("core.keymaps.util").map
local term = require("core.keymaps.opencode_term")

-- opencode 浮窗 toggle（纯 nvim API，不依赖 opencode.nvim 插件加载）。
-- 原因简述（Neovim 0.12+）：
-- 1) Terminal-Job（`t`）：空格等会先给 opencode，<Leader>… 往往匹配不到映射。
-- 2) Terminal-Normal（`nt`，即 <C-\><C-n> 之后）：`nmap`/`tmap` 都不生效，<Leader>co 不会被拦截，`c`/`o`
--    会按终端缓冲区的普通键处理，容易又回到 TUI 插入态，看起来像「关不掉」。
-- 对策：`t` 下用 <C-\><C-O> 插入一帧 Normal 执行 <Cmd>lua（不经过 Leader 解析）；`nt` 下请用命令
--    :OpencodeToggleWin 或先 <C-w>p 切到普通窗口再 <Leader>co。
local function focus_opencode_terminal_if_visible()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      local name = vim.api.nvim_buf_get_name(buf) or ""
      if name:match("term://") and name:match("opencode") then
        vim.api.nvim_set_current_win(win)
        vim.cmd("startinsert")
        return true
      end
    end
  end
  return false
end

local function opencode_toggle_lazy()
  term.toggle()
  vim.schedule(function()
    focus_opencode_terminal_if_visible()
  end)
end

vim.api.nvim_create_user_command("OpencodeToggleWin", function()
  opencode_toggle_lazy()
end, { desc = "切换 opencode 浮窗（任意模式可在命令行用）" })

vim.api.nvim_create_user_command("OpencodeStopWin", function()
  term.stop()
end, { desc = "关闭 opencode 终端 job（任意模式）" })

map("n", "<Leader>co", opencode_toggle_lazy, { desc = "Toggle opencode" })
-- Terminal-Job：`t` 映射 + <C-\><C-O> 让 Neovim 执行 toggle，不把 Leader 交给 PTY（与插件 README 的 <C-.> 思路一致）
vim.keymap.set(
  "t",
  "<Leader>co",
  "<C-\\><C-O><Cmd>lua require('core.keymaps.opencode_term').toggle()<CR>",
  { desc = "Toggle opencode（在 opencode TUI 内）", silent = true, remap = false }
)
map("n", "<Leader>aa", opencode_toggle_lazy, { desc = "Toggle opencode (same as <Leader>co)" })
map("t", "<F12>", "<C-\\><C-O><Cmd>lua require('core.keymaps.opencode_term').toggle()<CR>", { desc = "Toggle opencode（无 Leader）", silent = true, remap = false })
map("n", "<Leader>cO", function() term.stop() end, { desc = "Hide opencode (close only)" })
vim.keymap.set("t", "<Leader>cO", "<C-\\><C-O><Cmd>lua require('core.keymaps.opencode_term').stop()<CR>", { silent = true, remap = false })
map("n", "<Leader><Esc>", function() term.stop() end, { desc = "Hide opencode" })
vim.keymap.set("t", "<Leader><Esc>", "<C-\\><C-O><Cmd>lua require('core.keymaps.opencode_term').stop()<CR>", { silent = true, remap = false })
map("t", "<F11>", "<C-\\><C-O><Cmd>lua require('core.keymaps.opencode_term').stop()<CR>", { desc = "Stop opencode（无 Leader）", silent = true, remap = false })

-- 终端插入模式：回到上一窗口；若当前是浮窗终端（如 opencode），再隐藏浮窗以免挡在「前台」，进程仍保留
local function terminal_focus_prev_and_hide_float()
  local win = vim.api.nvim_get_current_win()
  local rel = vim.api.nvim_win_get_config(win).relative
  local is_float = rel ~= nil and rel ~= ""
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<C-\\><C-n><C-w>p", true, true, true),
    "n",
    false
  )
  if not is_float then
    return
  end
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_hide, win)
    end
  end, 0)
end
map("t", "<C-w>p", terminal_focus_prev_and_hide_float, { desc = "Terminal: prev window; hide float if any (keep job)" })

-- 选区分析/对话:把当前选区交给 opencode。
-- v0.14.0 惯用法：ask("@this: ") —— @this 在 visual 模式下由插件自动展开为当前选区
-- （opencode.context.selection 读取 <`/`> marks），opencode CLI 原生理解 @this 引用。
-- 插件是懒加载的，require 失败时先 Lazy load 再重试。
map({ "v", "x" }, "<Leader>aa", function()
  local ok, opencode = pcall(require, "opencode")
  if not ok then
    pcall(vim.cmd, "Lazy load opencode.nvim")
    ok, opencode = pcall(require, "opencode")
  end
  if ok and opencode.ask then
    opencode.ask("@this: ")
  else
    vim.notify("Opencode not available", vim.log.levels.WARN)
  end
end, { desc = "Opencode: analyze selection, open and chat" })

-- @file 占位符：先 <Leader>af 选文件，再在 ask 里输入 @file
map("n", "<Leader>af", function()
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then
    vim.notify("Telescope not available", vim.log.levels.WARN)
    return
  end
  builtin.find_files({
    attach_mappings = function(_, map_attach)
      map_attach("i", "<CR>", function(prompt_bufnr)
        local ok_actions, actions = pcall(require, "telescope.actions.state")
        if ok_actions then
          local sel = actions.get_selected_entry(prompt_bufnr)
          if sel and sel.value then
            vim.g.opencode_selected_file = sel.value
            vim.notify("Opencode 已选文件: " .. sel.value, vim.log.levels.INFO)
          end
        end
        require("telescope.actions").close(prompt_bufnr)
      end)
      return true
    end,
  })
end, { desc = "Select file for opencode (@file)" })
