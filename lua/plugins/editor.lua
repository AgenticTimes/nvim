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
          { "<leader>", mode = { "n", "v" } },
          { "<localleader>", mode = { "n", "v" } },
        },
      })

      -- Doom 风格分组标签（group 不加 +，由 icons.group 自动加）
      wk.add({
        { "<leader>h", group = "help", mode = { "n", "v" } },
        { "<leader>f", group = "file", mode = { "n", "v" } },
        { "<leader>b", group = "buffer", mode = { "n", "v" } },
        { "<leader>w", group = "window", mode = { "n", "v" } },
        { "<leader>p", group = "project", mode = { "n", "v" } },
        { "<leader>s", group = "search", mode = { "n", "v" } },
        { "<leader>g", group = "git", mode = { "n", "v" } },
        { "<leader>c", group = "code", mode = { "n", "v" } },
        { "<leader>q", group = "quit/session", mode = { "n", "v" } },
        { "<leader>t", group = "toggle", mode = { "n", "v" } },
        { "<leader>o", group = "open", mode = { "n", "v" } },
        { "<leader>a", group = "actions", mode = { "n", "v" } },
        { "<leader>u", group = "plugins", mode = { "n", "v" } },
        { "<leader>i", group = "insert", mode = { "n", "v" } },
        { "<leader>n", group = "notes", mode = { "n", "v" } },
        { "<leader><tab>", group = "workspace", mode = { "n", "v" } },
        { "<leader>[", group = "previous", mode = { "n", "v" } },
        { "<leader>]", group = "next", mode = { "n", "v" } },
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
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context",
    },
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

       require("treesitter-context").setup({
         enable = true,
         max_lines = 3,
         min_window_height = 0,
         line_numbers = true,
         multiline_threshold = 1,
         trim_scope = "outer",
         mode = "cursor",
         separator = nil,
       })
    end,
  },

  -- 目录当 buffer 编辑（vim-vinegar 风格）
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        default_file_explorer = true,
        columns = { "icon" },
        view_options = { show_hidden = false },
        keymaps = {
          ["q"] = "actions.close",
        },
      })
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory (oil)" })
    end,
  },

  -- 任务工作集（Doom：SPC RET 书签菜单 / SPC 1–9 跳转）
  {
    "otavioschwanck/arrow.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      show_icons = true,
      leader_key = false, -- 不用默认 `;`，改走 Doom SPC 键位
      save_key = "cwd",
    },
    keys = {
      {
        "<Leader><CR>",
        function()
          require("arrow.ui").openMenu()
        end,
        desc = "Arrow bookmarks (SPC RET)",
      },
      {
        "<Leader>bA",
        function()
          local path = require("arrow.utils").get_current_buffer_path()
          require("arrow.persist").toggle(path)
          local on = require("arrow.persist").is_saved(path)
          vim.notify(on and ("Arrow: pinned #" .. tostring(on)) or "Arrow: unpinned", vim.log.levels.INFO)
        end,
        desc = "Toggle arrow pin",
      },
      {
        "<Leader>1",
        function()
          require("arrow.persist").go_to(1)
        end,
        desc = "Arrow file 1",
      },
      {
        "<Leader>2",
        function()
          require("arrow.persist").go_to(2)
        end,
        desc = "Arrow file 2",
      },
      {
        "<Leader>3",
        function()
          require("arrow.persist").go_to(3)
        end,
        desc = "Arrow file 3",
      },
      {
        "<Leader>4",
        function()
          require("arrow.persist").go_to(4)
        end,
        desc = "Arrow file 4",
      },
      {
        "<Leader>5",
        function()
          require("arrow.persist").go_to(5)
        end,
        desc = "Arrow file 5",
      },
      {
        "<Leader>6",
        function()
          require("arrow.persist").go_to(6)
        end,
        desc = "Arrow file 6",
      },
      {
        "<Leader>7",
        function()
          require("arrow.persist").go_to(7)
        end,
        desc = "Arrow file 7",
      },
      {
        "<Leader>8",
        function()
          require("arrow.persist").go_to(8)
        end,
        desc = "Arrow file 8",
      },
      {
        "<Leader>9",
        function()
          require("arrow.persist").go_to(9)
        end,
        desc = "Arrow file 9",
      },
      {
        "<Leader>]a",
        function()
          require("arrow.persist").next()
        end,
        desc = "Next arrow file",
      },
      {
        "<Leader>[a",
        function()
          require("arrow.persist").previous()
        end,
        desc = "Prev arrow file",
      },
    },
  },

  -- 环绕编辑（Doom evil-surround：ys / cs / ds）
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- TODO/FIXME 高亮 + 搜索
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    keys = {
      { "<Leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
      { "<Leader>xT", "<cmd>TodoQuickFix<cr>", desc = "Todo quickfix" },
    },
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
            oil = true,
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
