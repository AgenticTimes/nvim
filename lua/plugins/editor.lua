-- 编辑基础:which-key 提示、文件树、括号、语法高亮、彩虹括号
return {
  -- which-key：Doom Emacs 风格（底部通栏多列，KEY : desc，+group）
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        -- Explicit classic geometry (don't rely on deferred preset merge alone)
        preset = "classic",
        delay = 300,
        win = {
          width = math.huge,
          height = { min = 4, max = 25 },
          col = 0,
          row = -1,
          border = "none",
          title = false,
          padding = { 0, 1 },
          wo = { winblend = 0 },
        },
        layout = {
          width = { min = 18, max = 50 },
          spacing = 2,
        },
        sort = { "local", "order", "group", "alphanum", "mod" },
        plugins = {
          spelling = {
            enabled = true,
            suggestions = 8,
          },
          marks = true,
          registers = true,
          presets = {
            operators = false,
            motions = false,
            text_objects = false,
            windows = false,
            nav = false,
            z = false,
            g = false,
          },
        },
        icons = {
          breadcrumb = "»",
          separator = " : ",
          group = "+",
          ellipsis = "…",
          mappings = false,
          rules = false,
          colors = false,
          keys = {
            Up = "<Up>",
            Down = "<Down>",
            Left = "<Left>",
            Right = "<Right>",
            C = "C-",
            M = "M-",
            D = "D-",
            S = "S-",
            CR = "RET",
            Esc = "ESC",
            ScrollWheelDown = "<ScrollWheelDown>",
            ScrollWheelUp = "<ScrollWheelUp>",
            NL = "RET",
            BS = "DEL",
            Space = "SPC",
            Tab = "TAB",
            F1 = "<F1>",
            F2 = "<F2>",
            F3 = "<F3>",
            F4 = "<F4>",
            F5 = "<F5>",
            F6 = "<F6>",
            F7 = "<F7>",
            F8 = "<F8>",
            F9 = "<F9>",
            F10 = "<F10>",
            F11 = "<F11>",
            F12 = "<F12>",
          },
        },
        show_help = true,
        show_keys = true,
        triggers = {
          { "<leader>", mode = "n" },
          { "<localleader>", mode = "n" },
        },
      })

      -- Doom 风格分组标签（group 不加 +，由 icons.group 自动加）
      wk.add({
        { "<leader>h", group = "help" },
        { "<leader>f", group = "file" },
        { "<leader>b", group = "buffer" },
        { "<leader>w", group = "window" },
        { "<leader>p", group = "project" },
        { "<leader>s", group = "search" },
        { "<leader>g", group = "git" },
        { "<leader>c", group = "code" },
        { "<leader>q", group = "quit/session" },
        { "<leader>t", group = "toggle" },
        { "<leader>o", group = "open" },
        { "<leader>a", group = "actions" },
        { "<leader>u", group = "plugins" },
        { "<leader>i", group = "insert" },
        { "<leader>n", group = "notes" },
        { "<leader><tab>", group = "workspace" },
        { "<leader>[", group = "previous" },
        { "<leader>]", group = "next" },
      })
    end,
  },

  -- 快捷键大全（legendary：可搜索的全部快捷键 + 命令 + autocmd）
  {
    "mrjones2014/legendary.nvim",
    dependencies = {
      "nvim-telescope/telescope-ui-select.nvim", -- 用 telescope 接管 vim.ui.select，实现模糊搜索
      "folke/which-key.nvim", -- 集成 which-key 注册的键位
    },
    event = "VeryLazy",
    config = function()
      require("legendary").setup({
        include_builtin = false,
        integrate = {
          which_key = false,
        },
      })
    end,
  },

  -- 快速跳转（flash：s 字符跳转 / S treesitter 节点 / r 远程跳转）
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash: jump to char" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash: jump to node" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
      {
        "R",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc = "Treesitter search",
      },
    },
  },

  -- 文件树
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeClose" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 30,
        },
        filters = {
          dotfiles = true,
        },
      })
      vim.keymap.set("n", "<Leader>e", ":NvimTreeToggle<CR>", { desc = "File tree" })
    end,
  },

  -- 语法高亮
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {},
    config = function()
       require("nvim-treesitter.configs").setup({
         ensure_installed = { "lua", "vim", "vimdoc", "javascript", "python" },
         highlight = { enable = true },
         incremental_selection = {
           enable = true,
           keymaps = {
             init_selection = "gnn",
             node_incremental = "grn",
             scope_incremental = "grc",
             node_decremental = "grm",
           },
         },
         indent = { enable = true },
         playground = {
           enable = true,
           updatetime = 25,
           persist_queries = false,
           keybindings = {
             toggle_query_editor = 'o',
             toggle_hl_groups = 'i',
             toggle_injected_languages = 't',
             toggle_anonymous_nodes = 'a',
             toggle_language_display = 'I',
             focus_language = 'f',
             unfocus_language = 'F',
             update = 'R',
             goto_node = '<cr>',
             show_help = '?',
           },
         },
       })
       -- Fix nvim-treesitter directives for Neovim 0.12.x compatibility.
       -- Neovim 0.12 changed match:captures() to return TSNode[] per capture ID,
       -- but nvim-treesitter's master branch (archived) treats it as a single TSNode.
       -- This overrides the broken directives with TSNode[]-aware versions.
       require("custom.fix-ts-directive")
    end,
  },

  -- 自动补全括号
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- 彩虹括号 (更好的语法高亮)
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
    config = function()
      local rainbow_delimiters = require "rainbow-delimiters"
      vim.g.rainbow_delimiters = {
        -- 无 parser / 特殊 UI 缓冲区：rainbow lib.attach 在 parser==nil 时会报错（如 NvimTree）
        condition = function(bufnr)
          if not vim.api.nvim_buf_is_valid(bufnr) then
            return false
          end
          local ft = vim.bo[bufnr].filetype
          local skip_ft = {
            NvimTree = true,
            ["neo-tree"] = true,
            ["neo-tree-popup"] = true,
            qf = true,
            help = true,
            lazy = true,
            lspinfo = true,
            notify = true,
          }
          if skip_ft[ft] then
            return false
          end
          local lang = vim.treesitter.language.get_lang(ft)
          if not lang then
            return false
          end
          local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
          if not ok or parser == nil then
            return false
          end
          return true
        end,
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
        },
        query = {
          [""] = "rainbow-delimiters",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
}
