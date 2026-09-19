-- 模糊搜索:telescope + fzf 扩展
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          -- 让搜索结果显示文件路径
          path_display = { "smart" },
          -- above pi ask popup (zindex=60) so vim.ui.select / @picker is never covered
          zindex = 100,
          -- 文件搜索时忽略的目录/模式
          file_ignore_patterns = {
            "^%.git/",
            "^node_modules/",
          },
        },
        pickers = {
          find_files = {
            -- 包含隐藏文件，但排除 .git 及 node_modules
            hidden = true,
            find_command = {
              "find", ".", "-type", "f",
              "-not", "-path", "*/.git/*",
              "-not", "-path", "*/node_modules/*",
            },
          },
        },
        extensions = {
          ["ui-select"] = require("telescope.themes").get_dropdown({
            -- above typical plugin floats (pi ask uses zindex 60)
            layout_config = { width = 0.6, height = 0.4 },
          }),
        },
      })
    end,
  },

  -- 更好的搜索界面 (fzf native)
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },

  -- 用 telescope 接管 vim.ui.select（legendary 快捷键面板、LSP 选择等支持模糊搜索）
  {
    "nvim-telescope/telescope-ui-select.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      -- ensure extension config applied even if telescope loaded first
      pcall(function()
        require("telescope").setup({
          extensions = {
            ["ui-select"] = require("telescope.themes").get_dropdown({
              layout_config = { width = 0.6, height = 0.4 },
            }),
          },
        })
      end)
      require("telescope").load_extension("ui-select")
    end,
  },

  -- 基于原生 fzf 的 picker（更快，大仓库优势明显）
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("fzf-lua").setup({
        -- 文件搜索后端：rg --files，排除 .git 与 node_modules
        files = {
          cmd = "rg --files --hidden --glob '!**/.git/**' --glob '!**/node_modules/**'",
        },
        -- grep 使用系统 rg
        grep = {
          rg_opts = "--hidden --smart-case -g '!**/.git/**' -g '!**/node_modules/**'",
        },
        winopts = {
          -- bat 未安装时回退到 fzf-lua 内置预览
          preview = { default = "builtin" },
        },
      })
    end,
  },
}
