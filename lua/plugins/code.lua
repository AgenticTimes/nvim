-- 代码工作流:Git 符号、终端、注释、代码便签、codegraph
return {
  -- Codegraph CLI UI（符号查询 / callers / callees / impact）
  {
    "AgenticTimes/codegraph.nvim",
    cmd = {
      "CodegraphQuery",
      "CodegraphCallers",
      "CodegraphCallees",
      "CodegraphImpact",
      "CodegraphSync",
    },
    keys = {
      -- 避开已有 <leader>c{a,c,e,i,m,o,…}；用 q/h/y/p/u
      {
        "<leader>cq",
        function()
          require("codegraph").query()
        end,
        mode = { "n", "v" },
        desc = "codegraph query (cword/selection)",
      },
      {
        "<leader>cQ",
        function()
          vim.ui.input({
            prompt = "codegraph query: ",
            default = vim.fn.expand("<cword>"),
          }, function(input)
            if input and input:match("%S") then
              require("codegraph").query(input)
            end
          end)
        end,
        desc = "codegraph query (prompt)",
      },
      {
        "<leader>ch",
        function()
          require("codegraph").callers()
        end,
        desc = "codegraph callers",
      },
      {
        "<leader>cy",
        function()
          require("codegraph").callees()
        end,
        desc = "codegraph callees",
      },
      {
        "<leader>cp",
        function()
          require("codegraph").impact()
        end,
        desc = "codegraph impact",
      },
      {
        "<leader>cu",
        function()
          require("codegraph").sync()
        end,
        desc = "codegraph sync",
      },
    },
    config = function()
      require("codegraph").setup({
        -- 主索引在 ~/source/.codegraph；在 ~/.config/nvim 等子索引里也会固定用它
        path = vim.fn.expand("~/source"),
        limit = 40,
        impact_depth = 2,
        picker = "auto",
      })
    end,
  },

  -- Git 集成 (类似Cursor的Git界面)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          delete = { text = "▎" },
          topdelete = { text = "▎" },
          changedelete = { text = "▎" },
          untracked = { text = "▎" },
        },
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 100,
        },
      })
    end,
  },

  -- Git diff / 历史（补 gitsigns 的整仓视图）
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles" },
    keys = {
      { "<Leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<Leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview file history" },
      { "<Leader>gx", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
    },
    opts = {},
  },

  -- 统一格式化（优先外部 formatter，否则 LSP）
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "gofmt" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        python = { "ruff_format", "black", stop_after_first = true },
        rust = { "rustfmt" },
      },
      default_format_opts = {
        lsp_format = "fallback",
        timeout_ms = 3000,
      },
      -- 不默认 format-on-save，避免意外改动；用 SPC cf 手动
    },
  },

  -- 诊断/引用聚合面板（trouble：Problems 面板）
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble", "TroubleToggle" },
    opts = {},
    keys = {
      { "<Leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<Leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<Leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
      { "<Leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
    },
  },

  -- 浮动终端
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        direction = "float",
        float_opts = {
          border = "rounded",
          width = 120,
          height = 30,
        },
      })
    end,
  },

  -- 代码注释便签（行级 annotation + 浮窗编辑）
  {
    "winter-again/annotate.nvim",
    dependencies = { "kkharji/sqlite.lua" },
    config = function()
      require("annotate").setup({
        db_uri = vim.fn.stdpath("data") .. "/annotations_db",
        annot_sign = "󰍕",
        annot_sign_hl = "Comment",
        annot_sign_hl_current = "FloatBorder",
        annot_win_width = 30,
        annot_win_padding = 2,
      })
    end,
  },
}
