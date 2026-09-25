-- Cursor风格Neovim配置
-- 将Neovim改造为类似Cursor编辑器的体验（无VSCode快捷键）

--[[
Cursor编辑器特性包含：
1. 现代化UI界面
2. AI编程助手集成
3. 智能项目管理
4. 强大的Git集成
5. AI增强的工作流
]]

-- Must be set before loading lazy.nvim
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- bootstrap lazy.nvim
require("core.bootstrap")

-- 加载Cursor风格核心配置
-- 环境/平台适配(PATH、剪贴板)
require("core.env")

-- 加载原始核心配置（兼容性）
require("core.options")
require("core.keymaps")
require("core.theme")

-- 静默自动保存
require("core.autosave")

-- 加载插件
require("plugins")

-- 加载Cursor风格插件 (现在通过lazy.nvim导入)

