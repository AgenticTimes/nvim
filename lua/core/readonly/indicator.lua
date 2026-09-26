-- 只读模式浮窗指示器:右上角 " R " 小浮窗
local M = {}

M.floating_win = nil
M.floating_buf = nil

---根据开关状态创建/销毁指示浮窗
---@param enabled boolean
function M.update(enabled)
  if M.floating_win and vim.api.nvim_win_is_valid(M.floating_win) then
    vim.api.nvim_win_close(M.floating_win, true)
    M.floating_win = nil
  end
  if M.floating_buf and vim.api.nvim_buf_is_valid(M.floating_buf) then
    vim.api.nvim_buf_delete(M.floating_buf, { force = true })
    M.floating_buf = nil
  end

  if enabled then
    -- 创建缓冲区
    M.floating_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(M.floating_buf, 0, -1, false, { " R " })
    vim.api.nvim_buf_set_option(M.floating_buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(M.floating_buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(M.floating_buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(M.floating_buf, 'readonly', true)

    -- 设置高亮
    vim.api.nvim_buf_add_highlight(M.floating_buf, -1, 'WarningMsg', 0, 0, -1)

    -- 计算位置（右上角）
    local width = 3  -- " R " 的长度
    local height = 1
    local row = 1      -- 离顶部一些间距
    local col = vim.o.columns - width - 1

    -- 创建窗口
    M.floating_win = vim.api.nvim_open_win(M.floating_buf, false, {
      relative = 'editor',
      width = width,
      height = height,
      row = row,
      col = col,
      style = 'minimal',
      border = 'rounded',
      focusable = false,
      zindex = 50,
    })

    -- 设置窗口选项
    vim.api.nvim_win_set_option(M.floating_win, 'winhl', 'Normal:WarningMsg,NormalNC:WarningMsg')
    vim.api.nvim_win_set_option(M.floating_win, 'winblend', 20)
  end
end

return M
