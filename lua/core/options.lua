-- 编辑器选项(权威来源)
-- 环境/平台适配见 core/env.lua;自动保存见 core/autosave.lua
local opt = vim.opt

-- 视觉设置
opt.number = true         -- 行号
opt.relativenumber = true -- 相对行号
opt.cursorline = true     -- 高亮当前行
opt.cursorcolumn = false
opt.signcolumn = "yes"    -- 始终显示标记列
opt.linespace = 8         -- 行间距（像素，GUI 下生效；终端内需在终端设置中调整）
opt.ruler = false
opt.cmdheight = 0
opt.showmatch = true
opt.more = false -- 多行消息不要求 Press ENTER（配合 cmdheight=0）
opt.shortmess:append("IWcC") -- 减少启动/补全噪音

-- 编辑设置
opt.expandtab = true      -- 空格替代Tab
opt.tabstop = 2           -- Tab宽度（原 core/cursor.lua 的 Cursor 风格值）
opt.shiftwidth = 2        -- 自动缩进宽度（与 tabstop 一致）
opt.smartindent = true    -- 智能缩进
opt.softtabstop = 2
opt.linebreak = true
opt.hidden = true
opt.swapfile = false
opt.backup = false

-- 搜索设置
opt.ignorecase = true     -- 忽略大小写
opt.smartcase = true      -- 智能大小写匹配
opt.hlsearch = true
opt.incsearch = true

-- 基本设置
opt.mouse = "a"
opt.clipboard = "unnamedplus"  -- 使用系统剪贴板（macOS provider 见 core/env.lua）
opt.undofile = true
opt.undodir = os.getenv("HOME") .. "/.local/state/nvim/undo//"
opt.termguicolors = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.updatetime = 100
opt.timeoutlen = 500
opt.title = true

-- 其他设置
opt.wrap = false
opt.showmode = false
opt.splitbelow = true
opt.splitright = true
opt.conceallevel = 0
opt.pumheight = 10
opt.fileformat = "unix"

-- 文件编码
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- GUI 字体设置（适用于 Neovim GUI 版本）
if vim.fn.has("gui_running") == 1 then
  -- 使用 PT Mono 字体，h16 表示大小 16
  -- 如果系统没有安装 PT Mono，会自动使用默认字体
  vim.opt.guifont = "PT Mono:h16"
end
