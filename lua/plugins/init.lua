-- lazy.nvim 装配入口
-- 插件 spec 按功能域拆分:
--   plugins/lsp.lua          LSP 全家(Mason + lspconfig)
--   plugins/cmp.lua          补全(nvim-cmp)
--   plugins/editor.lua       编辑基础(which-key/nvim-tree/treesitter/autopairs/rainbow)
--   plugins/finder.lua       模糊搜索(fzf-lua 为主 + telescope 供 ui-select/legendary 用)
--   plugins/statusline.lua   状态栏(lualine)
--   plugins/ai.lua           AI 集成(opencode/pi)
--   plugins/markdown.lua     Markdown 预览(render-markdown)
--   plugins/code.lua         代码工作流(gitsigns/toggleterm/Comment/annotate)
--   plugins/colorscheme.lua  配色方案(tokyonight/gruvbox)
local lazy = require("lazy")

-- 静默 lazy.nvim 的 markdown 通知（更新列表等），避免刷屏 + Press ENTER
do
  local notify = vim.notify
  vim.notify = function(msg, level, opts)
    opts = opts or {}
    if opts.title == "lazy.nvim" then
      return
    end
    return notify(msg, level, opts)
  end
end

lazy.setup({
  { import = "plugins.lsp" },
  { import = "plugins.cmp" },
  { import = "plugins.editor" },
  { import = "plugins.finder" },
  { import = "plugins.statusline" },
  { import = "plugins.ai" },
  { import = "plugins.markdown" },
  { import = "plugins.code" },
  { import = "plugins.colorscheme" },
}, {
  -- lazy.nvim 选项配置
  defaults = {
    lazy = true,
    version = false,
  },
  install = { colorscheme = { "desert", "tokyonight", "gruvbox" } },
  checker = {
    enabled = false, -- 关闭启动更新检查（需要时用 :Lazy check）
    notify = false,
  },
  change_detection = {
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
      preview = {
        timeout = 100,
        treesitter = true,
      },
    },
  },
})
