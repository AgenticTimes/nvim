-- 状态栏:lualine + trouble.nvim 扩展
return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "lewis6991/gitsigns.nvim",
    },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          globalstatus = true,
          component_separators = "|",
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            {
              "branch",
              fmt = function(s)
                return "󰘬 " .. s
              end,
            },
            "diff",
            "diagnostics",
          },
          lualine_c = { "filename" },
          lualine_x = {
            "encoding",
            "fileformat",
            "filetype",
            {
              "lsp",
              fmt = function()
                local clients = vim.lsp.get_clients()
                if #clients == 0 then
                  return ""
                end
                return "󰘦 " .. clients[1].name
              end,
            },
          },
          lualine_y = { "progress" },
          lualine_z = {
            "location",
            function()
              return vim.g.readonly_enabled and "󰈵 READONLY" or ""
            end,
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        extensions = { "nvim-tree", "toggleterm", "trouble" },
      })
    end,
  },
}
