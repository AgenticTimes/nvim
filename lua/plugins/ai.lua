-- AI 集成:opencode、pi
return {
  -- Opencode.nvim - opencode CLI plugin
  {
    "nickjvandyke/opencode.nvim",
    lazy = true,
    -- 注意：v0.14.0 起插件不再定义任何用户命令（旧版 Opencode/OpencodeToggle 已删除），
    -- 也不再提供内置终端管理器。浮窗终端由 core.keymaps.opencode_term 负责，
    -- 插件仅在 `,aa`（ask）等用到 Lua API 时由 keymap 里 Lazy load 触发加载。
    config = function()
      vim.o.autoread = true
      -- 完全禁用 ask 模态对话框
      vim.g.opencode_opts = {
        ask = {
          snacks = {
            win = {
              border = "rounded",
              width = 0.8,
              height = 0.8,
            },
          },
        },
      }
      -- 浮窗里显示完整 opencode TUI：由 core.keymaps.opencode_term 负责（纯 nvim API）。
      -- 插件 v0.14.0 删除了内置 terminal 管理器与 server.stop/server.toggle 配置项，
      -- 仅保留 server.start：discovery 找不到运行中的 opencode server 时调用（如直接 `,aa` ask）。
      -- 注意：不指定固定端口（默认随机端口）——固定端口可能与外部 `opencode serve`（如
      -- lark-channel-bridge 的远程桥接）冲突；端口被占时 opencode 会静默挂起、TUI 无法渲染。
      ---@type opencode.Opts
      -- vim.g 不能放函数、不能放混合 key 的 table，只放简单值；server 稍后直接写 opts
      -- vim.g.opencode_opts 已在上面设置
      local opencode_config_ok, opencode_config = pcall(require, "opencode.config")
      if not opencode_config_ok then
        vim.notify("Failed to load opencode.config, using default config", vim.log.levels.WARN)
        opencode_config = { opts = {} }
      end
      opencode_config.opts.server = {
        start = function()
          require("core.keymaps.opencode_term").open()
        end,
      }
      -- @file 占位符：先 <Leader>af 选文件，再在 ask 里输入 @file
      -- v0.14.0 的 Context.format 接受 opts 表（{ path = ... }），返回文件位置字符串
      opencode_config.opts.contexts = vim.tbl_extend("force", opencode_config.opts.contexts or {}, {
        ["@file"] = function(ctx)
          local path = vim.g.opencode_selected_file
          if not path or path == "" then return nil end
          local ok, result = pcall(require("opencode.context").format, { path = path })
          if ok then return result else return nil end
        end,
      })
      -- 确保 opencode 模块正确初始化
      local ok, opencode = pcall(require, "opencode")
      if ok then
        -- opencode.nvim exposes runtime APIs; no setup() on module table in current versions.
        -- Requiring the module here is enough to verify availability.
      else
        vim.notify("Failed to load opencode module: " .. tostring(opencode), vim.log.levels.ERROR)
      end
    end,
  },

  -- pi.nvim — 本地 Wave1+：RPC chat UI + host tools + multi-file review
  -- （替代 AgenticTimes/pi.neovim 的 TUI 默认路径）
  {
    dir = vim.fn.expand("~/source/pi.nvim"),
    name = "pi.nvim",
    lazy = false,
    config = function()
      require("pi").setup({
        keys = {
          toggle = "<leader>ai",
          submit = "<CR>", -- Enter 提交
          newline = "<C-j>", -- Ctrl+J 换行（终端里 Ctrl/Shift+Enter 不可靠）
          abort = "<C-c>",
          accept = "a",
          reject = "r",
          next_file = "]f",
          prev_file = "[f",
          mention = "@",
          history_prev = "<Up>",
          history_next = "<Down>",
          steer = "<C-s>",
        },
        busy_submit = "steer",
        write_on_accept = true,
        window = { width = 1.0, height = 1.0, layout = "full", border = "none" },
      })
      -- 避免 nvim-cmp 抢走 pi input 的 <CR>
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "pi://input",
        callback = function()
          local ok, cmp = pcall(require, "cmp")
          if ok and cmp.setup and cmp.setup.buffer then
            cmp.setup.buffer({ enabled = false })
          end
        end,
      })
    end,
  },
}
