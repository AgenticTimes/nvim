-- 缓冲区分类:判断哪些缓冲区不应被只读模式干预(提示/无文件/浮窗/特定 filetype)
local M = {}

---是否应跳过该缓冲区
---@param bufnr integer
---@return boolean
function M.should_skip(bufnr)
  local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

  -- 跳过提示缓冲区、无文件缓冲区、弹出窗口等
  if buftype == "prompt" or buftype == "nofile" or buftype == "popup" or buftype == "acwrite" or buftype == "quickfix" or buftype == "help" or buftype == "terminal" then
    return true
  end

  -- 跳过特定文件类型的缓冲区
  if filetype == "TelescopePrompt" or filetype == "neo-tree" or filetype == "NvimTree" or filetype == "oil" or filetype == "qf" or filetype == "help" or filetype == "fugitive" or filetype == "gitcommit" then
    return true
  end

  return false
end

return M
