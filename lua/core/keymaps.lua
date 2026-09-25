-- Doom Emacs风格快捷键 for Neovim
-- 基于Doom Emacs快捷键表的统一方案
-- Leader 为 Space，localleader 为逗号
--
-- 注意：
-- - mapleader/maplocalleader 在 init.lua 中设置（lazy.setup 之前）
-- - updatetime/timeoutlen 在 core/options.lua 中设置
-- - opencode 终端子系统在 core/keymaps/opencode.lua（require 时自动注册键位）

local map = require("core.keymaps.util").map
local safe_cmd = require("core.keymaps.util").safe_cmd
local fzf_lua = require("core.keymaps.util").fzf_lua

-- opencode 终端子系统（浮窗 toggle / t 模式转义 / 选区提取 / @file）
require("core.keymaps.opencode")

-- pi.nvim（pi coding agent 前端浮窗 / 模型 / 思考级别）
require("core.keymaps.pi")

-- ============================================================================
-- Doom Emacs风格快捷键 (SPC为Leader)
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Batch 1: SPC 根菜单（对齐 Doom +evil-bindings.el <leader> 顶层）
-- 冲突保留：SPC u* = Lazy/plugins（Doom 的 universal-argument 不覆盖）
-- ---------------------------------------------------------------------------
map("n", "<Leader>;", function()
  vim.ui.input({ prompt = "Eval: " }, function(expr)
    if not expr or expr == "" then
      return
    end
    local ok, result = pcall(vim.api.nvim_eval, expr)
    if not ok then
      local fn, err = load("return " .. expr)
      if not fn then
        ok, result = false, err
      else
        ok, result = pcall(fn)
      end
    end
    if ok then
      vim.notify(vim.inspect(result), vim.log.levels.INFO, { title = "Eval" })
    else
      vim.notify(tostring(result), vim.log.levels.ERROR, { title = "Eval" })
    end
  end)
end, { desc = "Eval expression" })

map("n", "<Leader>:", function()
  vim.ui.input({ prompt = "M-x " }, function(cmd)
    if cmd and cmd ~= "" then
      vim.cmd(cmd)
    end
  end)
end, { desc = "M-x" })

map("n", "<Leader>x", function()
  vim.cmd("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "hide"
  vim.bo.swapfile = false
  vim.bo.filetype = "markdown"
  vim.api.nvim_buf_set_name(0, "scratch://" .. tostring(vim.api.nvim_get_current_buf()))
end, { desc = "Pop up scratch buffer" })

map("n", "<Leader>X", function()
  -- Org Capture 近似：追加到 data/doom-capture.md
  local path = vim.fn.stdpath("data") .. "/doom-capture.md"
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  local stamp = os.date("%Y-%m-%d %H:%M")
  vim.api.nvim_buf_set_lines(0, -1, -1, false, { "", "## " .. stamp, "" })
  vim.cmd("normal! G")
end, { desc = "Org Capture (notes file)" })

-- SPC w / SPC h 为前缀（window / help），具体子键在后续 batch；根级无需 leaf
map("n", "<Leader>~", function()
  local closed = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local cfg = vim.api.nvim_win_get_config(win)
    if cfg.relative ~= "" then
      pcall(vim.api.nvim_win_close, win, false)
      closed = true
    end
  end
  if not closed then
    pcall(vim.cmd, "ToggleTerm")
  end
end, { desc = "Toggle last popup" })

map("n", "<Leader>.", fzf_lua("files"), { desc = "Find file" })
map("n", "<Leader>,", fzf_lua("buffers"), { desc = "Switch workspace buffer" })
map("n", "<Leader><", fzf_lua("buffers"), { desc = "Switch buffer" })
map("n", "<Leader>`", "<cmd>buffer #<cr>", { desc = "Switch to last buffer" })
-- SPC TAB → workspace（batch 5）；last buffer 只用 SPC `

map("n", "<Leader>'", fzf_lua("resume"), { desc = "Resume last search" })
map("n", "<Leader>*", fzf_lua("grep_cword"), { desc = "Search for symbol in project" })
map("n", "<Leader>/", fzf_lua("grep"), { desc = "Search project" })
map("n", "<Leader><Leader>", fzf_lua("files"), { desc = "Find file in project" })
map("n", "<Leader><CR>", fzf_lua("marks"), { desc = "Jump to bookmark" })

map("n", "<Leader>?", function()
  local ok = pcall(vim.cmd, "Legendary")
  if not ok then
    local wk_ok, which_key = pcall(require, "which-key")
    if wk_ok then
      which_key.show("", { mode = "n" })
    end
  end
end, { desc = "Search all keybindings (legendary)" })

-- help 前缀起步（Doom SPC h）
map("n", "<Leader>hh", fzf_lua("help_tags"), { desc = "Help tags" })
map("n", "<Leader>hk", fzf_lua("keymaps"), { desc = "Describe keybindings" })

-- ============================================================================
-- Batch 2: SPC f / b / w / p（对齐 Doom file/buffer/window/project）
-- ============================================================================

local function open_scratch()
  vim.cmd("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "hide"
  vim.bo.swapfile = false
  vim.bo.filetype = "markdown"
  pcall(vim.api.nvim_buf_set_name, 0, "scratch://" .. tostring(vim.api.nvim_get_current_buf()))
end

local function config_dir()
  return vim.fn.stdpath("config")
end

local function project_root()
  local ok, root = pcall(vim.fn.getcwd)
  if ok and root and root ~= "" then
    return root
  end
  return vim.fn.expand("%:p:h")
end

-- ---------- file (SPC f) ----------
map("n", "<Leader>ff", fzf_lua("files"), { desc = "Find file" })
map("n", "<Leader>fF", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.files({ cwd = vim.fn.expand("%:p:h") })
  end
end, { desc = "Find file from here" })
map("n", "<Leader>fd", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf.files then
    fzf.files({ cwd = vim.fn.expand("%:p:h"), fd_opts = "--type d" })
  else
    vim.cmd("Explore")
  end
end, { desc = "Find directory" })
map("n", "<Leader>fr", fzf_lua("oldfiles"), { desc = "Recent files" })
map("n", "<Leader>fs", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<Leader>fS", function()
  vim.ui.input({ prompt = "Save as: ", default = vim.fn.expand("%:p") }, function(path)
    if path and path ~= "" then
      vim.cmd("saveas " .. vim.fn.fnameescape(path))
    end
  end)
end, { desc = "Save file as..." })
map("n", "<Leader>fR", function()
  local old_name = vim.fn.expand("%:p")
  if old_name == "" then
    vim.notify("Buffer has no file name", vim.log.levels.WARN)
    return
  end
  vim.ui.input({ prompt = "Rename/move to: ", default = old_name }, function(new_name)
    if not new_name or new_name == "" or new_name == old_name then
      return
    end
    local ok, err = os.rename(old_name, new_name)
    if not ok then
      vim.notify("Rename failed: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    vim.cmd("edit " .. vim.fn.fnameescape(new_name))
    vim.cmd("bdelete! " .. vim.fn.bufnr(old_name))
  end)
end, { desc = "Rename/move file" })
map("n", "<Leader>fD", function()
  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("No file to delete", vim.log.levels.WARN)
    return
  end
  vim.ui.input({ prompt = "Delete " .. path .. "? [y/N] " }, function(ans)
    if ans and ans:lower() == "y" then
      vim.fn.delete(path)
      vim.cmd("bdelete!")
      vim.notify("Deleted " .. path, vim.log.levels.INFO)
    end
  end)
end, { desc = "Delete this file" })
map("n", "<Leader>fC", function()
  local src = vim.fn.expand("%:p")
  if src == "" then
    vim.notify("No file to copy", vim.log.levels.WARN)
    return
  end
  vim.ui.input({ prompt = "Copy to: ", default = src }, function(dst)
    if not dst or dst == "" then
      return
    end
    vim.cmd("saveas " .. vim.fn.fnameescape(dst))
  end)
end, { desc = "Copy this file" })
map("n", "<Leader>fy", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Yanked: " .. path, vim.log.levels.INFO)
end, { desc = "Yank file path" })
map("n", "<Leader>fY", function()
  local path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
  vim.fn.setreg("+", path)
  vim.notify("Yanked: " .. path, vim.log.levels.INFO)
end, { desc = "Yank file path from project" })
map("n", "<Leader>fe", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.files({ cwd = config_dir() })
  end
end, { desc = "Find file in emacs.d" })
map("n", "<Leader>fE", function()
  vim.cmd("edit " .. vim.fn.fnameescape(config_dir()))
end, { desc = "Browse emacs.d" })
map("n", "<Leader>fp", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.files({ cwd = config_dir() })
  end
end, { desc = "Find file in private config" })
map("n", "<Leader>fP", function()
  vim.cmd("edit " .. vim.fn.fnameescape(config_dir() .. "/init.lua"))
end, { desc = "Browse private config" })
map("n", "<Leader>fl", fzf_lua("files"), { desc = "Locate file" })
map("n", "<Leader>fc", function()
  local root = project_root()
  for _, name in ipairs({ ".editorconfig", "editorconfig" }) do
    local p = root .. "/" .. name
    if vim.fn.filereadable(p) == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(p))
      return
    end
  end
  vim.notify("No .editorconfig in " .. root, vim.log.levels.WARN)
end, { desc = "Open project editorconfig" })
map("n", "<Leader>fu", function()
  vim.ui.input({ prompt = "Sudo find file: " }, function(path)
    if path and path ~= "" then
      vim.cmd("edit sudo://" .. path)
    end
  end)
end, { desc = "Sudo find file" })
map("n", "<Leader>fU", function()
  local path = vim.fn.expand("%:p")
  if path ~= "" then
    vim.cmd("edit sudo://" .. path)
  end
end, { desc = "Sudo this file" })

-- ---------- buffer (SPC b) ----------
map("n", "<Leader>bb", fzf_lua("buffers"), { desc = "Switch workspace buffer" })
map("n", "<Leader>bB", fzf_lua("buffers"), { desc = "Switch buffer" })
map("n", "<Leader>b[", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<Leader>b]", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<Leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<Leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<Leader>bk", "<cmd>bdelete<cr>", { desc = "Kill buffer" })
map("n", "<Leader>bd", "<cmd>bdelete<cr>", { desc = "Kill buffer" })
map("n", "<Leader>bK", "<cmd>bufdo bdelete<cr>", { desc = "Kill all buffers" })
map("n", "<Leader>bO", function()
  local cur = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= cur and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      pcall(vim.api.nvim_buf_delete, buf, { force = false })
    end
  end
end, { desc = "Kill other buffers" })
map("n", "<Leader>bl", "<cmd>buffer #<cr>", { desc = "Switch to last buffer" })
map("n", "<Leader>bN", "<cmd>enew<cr>", { desc = "New empty buffer" })
map("n", "<Leader>br", "<cmd>edit!<cr>", { desc = "Revert buffer" })
map("n", "<Leader>bR", function()
  vim.ui.input({ prompt = "Rename buffer: ", default = vim.api.nvim_buf_get_name(0) }, function(name)
    if name and name ~= "" then
      vim.api.nvim_buf_set_name(0, name)
    end
  end)
end, { desc = "Rename buffer" })
map("n", "<Leader>bs", "<cmd>w<cr>", { desc = "Save buffer" })
map("n", "<Leader>bS", "<cmd>wa<cr>", { desc = "Save all buffers" })
map("n", "<Leader>bx", open_scratch, { desc = "Pop up scratch buffer" })
map("n", "<Leader>bX", function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("^scratch://") then
      vim.api.nvim_set_current_buf(buf)
      return
    end
  end
  open_scratch()
end, { desc = "Switch to scratch buffer" })
map("n", "<Leader>by", function()
  vim.cmd("%y+")
  vim.notify("Yanked buffer contents", vim.log.levels.INFO)
end, { desc = "Yank buffer" })
map("n", "<Leader>bz", "<cmd>bprevious<cr><cmd>bdelete #<cr>", { desc = "Bury buffer" })
map("n", "<Leader>bZ", function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and not vim.bo[buf].buflisted then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end, { desc = "Kill buried buffers" })
map("n", "<Leader>bi", fzf_lua("buffers"), { desc = "ibuffer" })
map("n", "<Leader>bm", function()
  vim.ui.input({ prompt = "Mark name: " }, function(m)
    if m and #m == 1 then
      vim.cmd("mark " .. m)
    end
  end)
end, { desc = "Set bookmark" })
map("n", "<Leader>bM", function()
  vim.ui.input({ prompt = "Delete mark: " }, function(m)
    if m and #m == 1 then
      vim.cmd("delmarks " .. m)
    end
  end)
end, { desc = "Delete bookmark" })
map("n", "<Leader>b-", function()
  vim.cmd("normal! zn") -- open folds / crude narrow toggle offline
  vim.notify("Narrowing: use visual + :'<,'>fold or treesitter (approx)", vim.log.levels.INFO)
end, { desc = "Toggle narrowing (approx)" })
map("n", "<Leader>bc", "<cmd>vsplit<cr>", { desc = "Clone buffer" })
map("n", "<Leader>bC", "<cmd>split<cr>", { desc = "Clone buffer other window" })
map("n", "<Leader>bu", function()
  local path = vim.fn.expand("%:p")
  if path ~= "" then
    vim.cmd("write sudo://" .. path)
  end
end, { desc = "Save buffer as root" })

-- ---------- window (SPC w) — Doom evil-window-map 近似 ----------
map("n", "<Leader>ws", "<C-w>s", { desc = "Split below" })
map("n", "<Leader>wv", "<C-w>v", { desc = "Split right" })
map("n", "<Leader>wd", "<C-w>c", { desc = "Delete window" })
map("n", "<Leader>wc", "<C-w>c", { desc = "Close window" })
map("n", "<Leader>wo", "<C-w>o", { desc = "Delete other windows" })
map("n", "<Leader>ww", "<C-w>w", { desc = "Other window" })
map("n", "<Leader>wp", "<C-w>p", { desc = "Previous window" })
map("n", "<Leader>wh", "<C-w>h", { desc = "Window left" })
map("n", "<Leader>wj", "<C-w>j", { desc = "Window down" })
map("n", "<Leader>wk", "<C-w>k", { desc = "Window up" })
map("n", "<Leader>wl", "<C-w>l", { desc = "Window right" })
map("n", "<Leader>wH", "<C-w>H", { desc = "Move window left" })
map("n", "<Leader>wJ", "<C-w>J", { desc = "Move window down" })
map("n", "<Leader>wK", "<C-w>K", { desc = "Move window up" })
map("n", "<Leader>wL", "<C-w>L", { desc = "Move window right" })
map("n", "<Leader>w=", "<C-w>=", { desc = "Balance windows" })
map("n", "<Leader>w+", "<cmd>resize +5<cr>", { desc = "Increase height" })
map("n", "<Leader>w-", "<cmd>resize -5<cr>", { desc = "Decrease height" })
map("n", "<Leader>w>", "<cmd>vertical resize +5<cr>", { desc = "Increase width" })
map("n", "<Leader>w<", "<cmd>vertical resize -5<cr>", { desc = "Decrease width" })
map("n", "<Leader>wm", "<C-w>_<C-w>|", { desc = "Maximize window" })
map("n", "<Leader>w_", "<C-w>_", { desc = "Maximize height" })
map("n", "<Leader>w|", "<C-w>|", { desc = "Maximize width" })
map("n", "<Leader>wr", "<C-w>r", { desc = "Rotate windows" })
map("n", "<Leader>wR", "<C-w>R", { desc = "Rotate windows reverse" })
map("n", "<Leader>wT", "<C-w>T", { desc = "Break out into tab" })
map("n", "<Leader>wq", "<C-w>q", { desc = "Quit window" })

-- ---------- project (SPC p) ----------
-- 注意：不再把 SPC p 映射为 paste（与 Doom +project 冲突）；粘贴见 SPC yp
map("n", "<Leader>pp", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf.files then
    -- 无 project.nvim：用目录选择近似「切换项目」
    fzf.files({
      cwd = vim.fn.expand("~"),
      fd_opts = "--type d --max-depth 3",
      actions = {
        ["default"] = function(selected)
          local dir = selected[1]
          if dir then
            vim.cmd("cd " .. vim.fn.fnameescape(dir))
            vim.notify("Project cwd: " .. dir, vim.log.levels.INFO)
          end
        end,
      },
    })
  else
    vim.ui.input({ prompt = "cd to project: ", default = vim.fn.getcwd() }, function(dir)
      if dir and dir ~= "" then
        vim.cmd("cd " .. vim.fn.fnameescape(dir))
      end
    end)
  end
end, { desc = "Switch project" })
map("n", "<Leader>pf", fzf_lua("files"), { desc = "Find file in project" })
map("n", "<Leader>pF", fzf_lua("files"), { desc = "Find file in other project" })
map("n", "<Leader>pb", fzf_lua("buffers"), { desc = "Switch to project buffer" })
map("n", "<Leader>pr", fzf_lua("oldfiles"), { desc = "Find recent project files" })
map("n", "<Leader>p.", function()
  vim.cmd("edit " .. vim.fn.fnameescape(project_root()))
end, { desc = "Browse project" })
map("n", "<Leader>p/", fzf_lua("grep"), { desc = "Search in project" })
map("n", "<Leader>pt", "<cmd>NvimTreeToggle<cr>", { desc = "Project file tree" })
map("n", "<Leader>pc", "<cmd>make<cr>", { desc = "Compile in project" })
map("n", "<Leader>ps", "<cmd>wa<cr>", { desc = "Save project files" })
map("n", "<Leader>pk", function()
  local cur = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      pcall(vim.api.nvim_buf_delete, buf, { force = false })
    end
  end
  if vim.api.nvim_buf_is_valid(cur) then
    vim.api.nvim_set_current_buf(cur)
  end
end, { desc = "Kill project buffers" })
map("n", "<Leader>p!", function()
  vim.ui.input({ prompt = "Project cmd: " }, function(cmd)
    if cmd and cmd ~= "" then
      vim.cmd("!" .. cmd)
    end
  end)
end, { desc = "Run cmd in project root" })
map("n", "<Leader>p&", function()
  vim.ui.input({ prompt = "Async project cmd: " }, function(cmd)
    if cmd and cmd ~= "" then
      vim.fn.jobstart(cmd, { cwd = project_root(), detach = true })
      vim.notify("Started: " .. cmd, vim.log.levels.INFO)
    end
  end)
end, { desc = "Async cmd in project root" })
map("n", "<Leader>px", open_scratch, { desc = "Pop up scratch buffer" })
map("n", "<Leader>pX", function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match("^scratch://") then
      vim.api.nvim_set_current_buf(buf)
      return
    end
  end
  open_scratch()
end, { desc = "Switch to scratch buffer" })

-- ============================================================================
-- Batch 3: SPC s / g / c（对齐 Doom search / git / code）
-- ============================================================================

-- ---------- search (SPC s) ----------
map("n", "<Leader>sb", fzf_lua("blines"), { desc = "Search buffer" })
map("n", "<Leader>ss", fzf_lua("blines"), { desc = "Search buffer" })
map("n", "<Leader>sS", fzf_lua("grep_cword"), { desc = "Search buffer for thing at point" })
map("n", "<Leader>sB", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf.lines then
    fzf.lines()
  elseif ok then
    fzf.grep({ search = "", fzf_opts = { ["--multi"] = true } })
  end
end, { desc = "Search all open buffers" })
map("n", "<Leader>sd", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.grep({ cwd = vim.fn.expand("%:p:h") })
  end
end, { desc = "Search current directory" })
map("n", "<Leader>sD", function()
  vim.ui.input({ prompt = "Search directory: ", default = vim.fn.getcwd() }, function(dir)
    if not dir or dir == "" then
      return
    end
    local ok, fzf = pcall(require, "fzf-lua")
    if ok then
      fzf.grep({ cwd = dir })
    end
  end)
end, { desc = "Search other directory" })
map("n", "<Leader>se", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.grep({ cwd = vim.fn.stdpath("config") })
  end
end, { desc = "Search .emacs.d" })
map("n", "<Leader>sf", fzf_lua("files"), { desc = "Locate file" })
map("n", "<Leader>si", fzf_lua("lsp_document_symbols"), { desc = "Jump to symbol" })
map("n", "<Leader>sI", fzf_lua("lsp_workspace_symbols"), { desc = "Jump to symbol in open buffers" })
map("n", "<Leader>sp", fzf_lua("grep"), { desc = "Search project" })
map("n", "<Leader>sP", fzf_lua("grep"), { desc = "Search other project" })
map("n", "<Leader>sm", fzf_lua("marks"), { desc = "Jump to bookmark" })
map("n", "<Leader>sr", fzf_lua("marks"), { desc = "Jump to mark" })
map("n", "<Leader>sj", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf.jumps then
    fzf.jumps()
  else
    vim.cmd("jumps")
  end
end, { desc = "Jump list" })
map("n", "<Leader>so", function()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    return
  end
  local url = "https://duckduckgo.com/?q=" .. vim.fn.escape(word, " ")
  vim.fn.jobstart({ "open", url }, { detach = true })
end, { desc = "Look up online" })
map("n", "<Leader>sO", function()
  vim.ui.input({ prompt = "Search online: ", default = vim.fn.expand("<cword>") }, function(q)
    if not q or q == "" then
      return
    end
    local url = "https://duckduckgo.com/?q=" .. vim.fn.escape(q, " ")
    vim.fn.jobstart({ "open", url }, { detach = true })
  end)
end, { desc = "Look up online (w/ prompt)" })
map("n", "<Leader>su", function()
  if vim.fn.exists(":UndotreeToggle") == 2 then
    vim.cmd("UndotreeToggle")
  else
    vim.cmd("undolist")
  end
end, { desc = "Undo history" })
map("n", "<Leader>sh", fzf_lua("help_tags"), { desc = "Search help tags" })
-- 保留非 Doom 但常用的 resume（Doom resume 在 SPC '）
map("n", "<Leader>s.", fzf_lua("resume"), { desc = "Resume last search" })

map("n", "*", "*", { desc = "Search word under cursor forward" })
map("n", "#", "#", { desc = "Search word under cursor backward" })

-- ---------- code (SPC c) ----------
-- 注意：SPC co / cO 留给 opencode（见 keymaps/opencode.lua）
map("n", "<Leader>ca", function()
  vim.lsp.buf.code_action()
end, { desc = "LSP Execute code action" })
map("n", "<Leader>cr", function()
  vim.lsp.buf.rename()
end, { desc = "LSP Rename" })
map("n", "<Leader>cd", vim.lsp.buf.definition, { desc = "Jump to definition" })
map("n", "<Leader>cD", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf.lsp_references then
    fzf.lsp_references()
  else
    vim.lsp.buf.references()
  end
end, { desc = "Jump to references" })
map("n", "<Leader>ci", function()
  vim.lsp.buf.implementation()
end, { desc = "Find implementations" })
map("n", "<Leader>ct", function()
  vim.lsp.buf.type_definition()
end, { desc = "Find type definition" })
map("n", "<Leader>ck", function()
  vim.lsp.buf.hover()
end, { desc = "Jump to documentation" })
map("n", "<Leader>cj", fzf_lua("lsp_workspace_symbols"), { desc = "Jump to symbol in current workspace" })
map("n", "<Leader>cJ", fzf_lua("lsp_workspace_symbols"), { desc = "Jump to symbol in any workspace" })
map("n", "<Leader>cf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer/region" })
map("n", "<Leader>cx", function()
  local ok = pcall(vim.cmd, "Trouble diagnostics toggle")
  if not ok then
    vim.diagnostic.setqflist()
  end
end, { desc = "List errors" })
map("n", "<Leader>cc", "<cmd>make<cr>", { desc = "Compile" })
map("n", "<Leader>cC", "<cmd>make!<cr>", { desc = "Recompile" })
map("n", "<Leader>ce", function()
  if vim.bo.filetype == "lua" then
    vim.cmd("source %")
    vim.notify("Buffer evaluated", vim.log.levels.INFO)
  else
    vim.cmd("make")
  end
end, { desc = "Evaluate buffer/region" })
map("n", "<Leader>cE", function()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" then
    vim.cmd("normal! y")
    local expr = vim.fn.getreg('"')
    local fn, err = load("return " .. expr)
    if not fn then
      vim.notify(tostring(err), vim.log.levels.ERROR)
      return
    end
    local ok, result = pcall(fn)
    if ok then
      vim.notify(vim.inspect(result), vim.log.levels.INFO)
    else
      vim.notify(tostring(result), vim.log.levels.ERROR)
    end
  else
    vim.notify("Select a region first", vim.log.levels.WARN)
  end
end, { desc = "Evaluate & replace region" })
map("n", "<Leader>cs", "<cmd>ToggleTerm<cr>", { desc = "Send to repl" })
map("n", "<Leader>cw", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.winrestview(view)
end, { desc = "Delete trailing whitespace" })
map("n", "<Leader>cW", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[%s/\n\+\%$//e]])
  vim.fn.winrestview(view)
end, { desc = "Delete trailing newlines" })
map("n", "<Leader>cl", "<cmd>LspInfo<cr>", { desc = "LSP" })

-- ---------- git (SPC g) — gitsigns + fzf-lua / git CLI（无 Magit） ----------
map("n", "<Leader>gg", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf.git_status then
    fzf.git_status()
  else
    vim.cmd("!git status")
  end
end, { desc = "Git status" })
map("n", "<Leader>gG", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf.git_status then
    fzf.git_status()
  end
end, { desc = "Git status here" })
map("n", "<Leader>gb", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf.git_branches then
    fzf.git_branches()
  end
end, { desc = "Switch branch" })
map("n", "<Leader>gB", function()
  local ok = pcall(vim.cmd, "Gitsigns blame_line")
  if not ok then
    vim.cmd("!git blame %")
  end
end, { desc = "Git blame" })
map("n", "<Leader>g]", function()
  pcall(vim.cmd, "Gitsigns next_hunk")
end, { desc = "Jump to next hunk" })
map("n", "<Leader>g[", function()
  pcall(vim.cmd, "Gitsigns prev_hunk")
end, { desc = "Jump to previous hunk" })
map("n", "<Leader>gs", function()
  pcall(vim.cmd, "Gitsigns stage_hunk")
end, { desc = "Stage hunk at point" })
map("n", "<Leader>gr", function()
  pcall(vim.cmd, "Gitsigns reset_hunk")
end, { desc = "Revert hunk at point" })
map("n", "<Leader>gS", function()
  pcall(vim.cmd, "Gitsigns stage_buffer")
end, { desc = "Git stage this file" })
map("n", "<Leader>gU", function()
  pcall(vim.cmd, "Gitsigns undo_stage_hunk")
end, { desc = "Git unstage this file" })
map("n", "<Leader>gR", function()
  pcall(vim.cmd, "Gitsigns reset_buffer")
end, { desc = "Revert file" })
map("n", "<Leader>gc", function()
  vim.ui.input({ prompt = "Commit message: " }, function(msg)
    if not msg or msg == "" then
      return
    end
    vim.fn.system({ "git", "commit", "-m", msg })
    vim.notify(vim.v.shell_error == 0 and "Committed" or "Commit failed", vim.log.levels.INFO)
  end)
end, { desc = "Commit" })
map("n", "<Leader>gL", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf.git_bcommits then
    fzf.git_bcommits()
  elseif ok and fzf.git_commits then
    fzf.git_commits()
  end
end, { desc = "Git buffer log" })
map("n", "<Leader>gF", function()
  vim.fn.jobstart({ "git", "fetch", "--all" }, {
    detach = false,
    on_exit = function(_, code)
      vim.schedule(function()
        vim.notify(code == 0 and "Fetched" or "Fetch failed", vim.log.levels.INFO)
      end)
    end,
  })
end, { desc = "Git fetch" })
map("n", "<Leader>gf", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf.git_files then
    fzf.git_files()
  end
end, { desc = "Find file" })
map("n", "<Leader>gy", function()
  local path = vim.fn.expand("%:p")
  local line = vim.fn.line(".")
  local remote = vim.fn.systemlist("git config --get remote.origin.url")[1] or ""
  vim.fn.setreg("+", string.format("%s#L%d", path, line))
  vim.notify("Yanked path (remote: " .. remote .. ")", vim.log.levels.INFO)
end, { desc = "Copy link to remote (approx path)" })

-- ============================================================================
-- 上一项/下一项 (SPC [ / SPC ])
-- ============================================================================
map("n", "<Leader>[e", "<cmd>lprev<cr>", { desc = "Previous error" })
map("n", "<Leader>]e", "<cmd>lnext<cr>", { desc = "Next error" })
map("n", "<Leader>[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<Leader>]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<Leader>[s", "<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.WARN})<cr>", { desc = "Previous spelling error" })
map("n", "<Leader>]s", "<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.WARN})<cr>", { desc = "Next spelling error" })

-- ============================================================================
-- Batch 4: SPC t / o / q（对齐 Doom toggle / open / quit/session）
-- ============================================================================

-- ---------- toggle (SPC t) ----------
map("n", "<Leader>tl", function()
  if vim.wo.number and vim.wo.relativenumber then
    vim.wo.relativenumber = false
  elseif vim.wo.number then
    vim.wo.number = false
  else
    vim.wo.number = true
    vim.wo.relativenumber = true
  end
end, { desc = "Line numbers" })
map("n", "<Leader>ts", "<cmd>set spell!<cr>", { desc = "Spell checker" })
map("n", "<Leader>tr", function()
  local ok, readonly = pcall(require, "core.readonly")
  if ok then
    readonly.toggle()
  else
    vim.wo.readonly = not vim.wo.readonly
  end
end, { desc = "Read-only mode" })
map("n", "<Leader>tR", function()
  local ok, readonly = pcall(require, "core.readonly")
  if ok then
    if readonly.enabled then
      readonly.disable_all()
    else
      readonly.enable_all()
    end
  end
end, { desc = "Read-only mode for all buffers" })
map("n", "<Leader>tc", function()
  if vim.wo.colorcolumn == "" or vim.wo.colorcolumn == "0" then
    vim.wo.colorcolumn = "80"
  else
    vim.wo.colorcolumn = ""
  end
end, { desc = "Fill Column Indicator" })
map("n", "<Leader>td", function()
  pcall(vim.cmd, "Gitsigns toggle_signs")
end, { desc = "Diff Highlights (Git Gutter)" })
map("n", "<Leader>tf", function()
  local enabled = vim.diagnostic.is_enabled and vim.diagnostic.is_enabled()
  if enabled == nil then
    -- older API
    vim.diagnostic.enable(not vim.g._doom_diag_off)
    vim.g._doom_diag_off = not vim.g._doom_diag_off
  else
    vim.diagnostic.enable(not enabled)
  end
end, { desc = "Flycheck" })
map("n", "<Leader>tF", function()
  if vim.fn.exists("+fullscreen") == 1 then
    vim.cmd("set fullscreen!")
  elseif vim.fn.has("gui_running") == 1 then
    vim.notify("Fullscreen toggle depends on GUI", vim.log.levels.INFO)
  else
    vim.notify("Fullscreen not available in TUI", vim.log.levels.INFO)
  end
end, { desc = "Frame fullscreen" })
map("n", "<Leader>tw", "<cmd>set wrap!<cr>", { desc = "Soft line wrapping" })
map("n", "<Leader>tb", function()
  if vim.fn.has("gui_running") ~= 1 then
    vim.notify("Big mode needs GUI font", vim.log.levels.WARN)
    return
  end
  local current = vim.opt.guifont:get()[1] or "Menlo:h14"
  local size = tonumber(current:match("h(%d+)")) or 14
  local big = size >= 20
  local new_size = big and 14 or 22
  vim.opt.guifont = current:gsub("h%d+", "h" .. new_size)
end, { desc = "Big mode" })
map("n", "<Leader>tv", "<cmd>set list!<cr>", { desc = "Visible mode" })
map("n", "<Leader>tI", function()
  if vim.bo.expandtab then
    vim.bo.expandtab = false
    vim.notify("Indent: tabs", vim.log.levels.INFO)
  else
    vim.bo.expandtab = true
    vim.notify("Indent: spaces", vim.log.levels.INFO)
  end
end, { desc = "Indent style" })

-- ---------- open (SPC o) ----------
map("n", "<Leader>o-", "<cmd>Oil<cr>", { desc = "Oil (edit directory)" })
map("n", "<Leader>ot", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal popup" })
map("n", "<Leader>oT", function()
  local ok, term = pcall(require, "toggleterm.terminal")
  if ok then
    local Terminal = require("toggleterm.terminal").Terminal
    Terminal:new({ dir = vim.fn.expand("%:p:h"), direction = "float" }):toggle()
  else
    vim.cmd("terminal")
  end
end, { desc = "Open terminal here" })
map("n", "<Leader>op", "<cmd>NvimTreeToggle<cr>", { desc = "Project sidebar" })
map("n", "<Leader>oP", "<cmd>NvimTreeFindFileToggle<cr>", { desc = "Find file in project sidebar" })
map("n", "<Leader>of", "<cmd>tabnew<cr>", { desc = "New frame" })
map("n", "<Leader>oF", "<cmd>tabs<cr>", { desc = "Select frame" })
map("n", "<Leader>or", "<cmd>ToggleTerm<cr>", { desc = "REPL" })
map("n", "<Leader>oR", "<cmd>terminal<cr>", { desc = "REPL (same window)" })
map("n", "<Leader>ob", function()
  local path = vim.fn.expand("%:p")
  if path == "" then
    vim.notify("No file", vim.log.levels.WARN)
    return
  end
  vim.fn.jobstart({ "open", path }, { detach = true })
end, { desc = "Default browser" })
map("n", "<Leader>oo", function()
  local path = vim.fn.expand("%:p")
  if path == "" then
    path = vim.fn.getcwd()
  end
  vim.fn.jobstart({ "open", "-R", path }, { detach = true })
end, { desc = "Reveal in Finder" })
map("n", "<Leader>oO", function()
  vim.fn.jobstart({ "open", vim.fn.getcwd() }, { detach = true })
end, { desc = "Reveal project in Finder" })
map("n", "<Leader>oi", function()
  vim.fn.jobstart({ "open", "-a", "iTerm", vim.fn.getcwd() }, { detach = true })
end, { desc = "Open in iTerm" })
map("n", "<Leader>oI", function()
  vim.fn.jobstart({ "open", "-na", "iTerm", vim.fn.getcwd() }, { detach = true })
end, { desc = "Open in new iTerm window" })
map("n", "<Leader>oa", function()
  local path = vim.fn.stdpath("data") .. "/doom-capture.md"
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end, { desc = "Agenda (capture notes)" })
map("n", "<Leader>oA", function()
  local path = vim.fn.stdpath("data") .. "/doom-capture.md"
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end, { desc = "Org agenda" })

-- ---------- quit/session (SPC q) ----------
map("n", "<Leader>qq", "<cmd>confirm qa<cr>", { desc = "Quit Emacs" })
map("n", "<Leader>qQ", "<cmd>qa!<cr>", { desc = "Quit Emacs without saving" })
map("n", "<Leader>qf", "<cmd>tabclose<cr>", { desc = "Delete frame" })
map("n", "<Leader>qF", function()
  local cur = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= cur and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
      pcall(vim.api.nvim_buf_delete, buf, { force = false })
    end
  end
end, { desc = "Clear current frame" })
map("n", "<Leader>qK", "<cmd>qa!<cr>", { desc = "Kill Emacs (and daemon)" })
map("n", "<Leader>qR", function()
  vim.cmd("qa")
  -- GUI/restart not always available; user restarts nvim
end, { desc = "Restart Emacs" })
map("n", "<Leader>qs", function()
  vim.cmd("mksession! " .. vim.fn.stdpath("state") .. "/doom-session.vim")
  vim.notify("Session saved", vim.log.levels.INFO)
end, { desc = "Quick save current session" })
map("n", "<Leader>ql", function()
  local s = vim.fn.stdpath("state") .. "/doom-session.vim"
  if vim.fn.filereadable(s) == 1 then
    vim.cmd("source " .. vim.fn.fnameescape(s))
  else
    vim.notify("No session file", vim.log.levels.WARN)
  end
end, { desc = "Restore last session" })
map("n", "<Leader>qS", function()
  vim.ui.input({ prompt = "Save session as: ", default = vim.fn.stdpath("state") .. "/session.vim" }, function(path)
    if path and path ~= "" then
      vim.cmd("mksession! " .. vim.fn.fnameescape(path))
    end
  end)
end, { desc = "Save session to file" })
map("n", "<Leader>qL", function()
  vim.ui.input({ prompt = "Load session: ", default = vim.fn.stdpath("state") .. "/session.vim" }, function(path)
    if path and path ~= "" and vim.fn.filereadable(path) == 1 then
      vim.cmd("source " .. vim.fn.fnameescape(path))
    end
  end)
end, { desc = "Restore session from file" })

-- ============================================================================
-- Batch 5: SPC i / n / TAB（insert / notes / workspace≈tabs）
-- ============================================================================

local function notes_dir()
  local dir = vim.fn.stdpath("data") .. "/doom-notes"
  vim.fn.mkdir(dir, "p")
  return dir
end

-- ---------- insert (SPC i) ----------
map("n", "<Leader>if", function()
  local name = vim.fn.expand("%:t")
  vim.api.nvim_put({ name }, "c", true, true)
end, { desc = "Current file name" })
map("n", "<Leader>iF", function()
  local path = vim.fn.expand("%:p")
  vim.api.nvim_put({ path }, "c", true, true)
end, { desc = "Current file path" })
map("n", "<Leader>iu", function()
  vim.ui.input({ prompt = "Unicode codepoint / char: " }, function(s)
    if not s or s == "" then
      return
    end
    if s:match("^%d+$") or s:match("^U%+") or s:match("^0x") then
      local n = tonumber(s:gsub("U%+", "0x"):gsub("^0x", ""), 16) or tonumber(s)
      if n then
        vim.api.nvim_put({ vim.fn.nr2char(n) }, "c", true, true)
      end
    else
      vim.api.nvim_put({ s }, "c", true, true)
    end
  end)
end, { desc = "Unicode" })
map("n", "<Leader>iy", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf.registers then
    fzf.registers()
  else
    vim.cmd('normal! "+p')
  end
end, { desc = "From clipboard" })
map("n", "<Leader>ir", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf.registers then
    fzf.registers()
  else
    vim.cmd("registers")
  end
end, { desc = "From evil register" })
map("n", "<Leader>is", function()
  if vim.fn.exists(":LuaSnipListAvailable") == 2 or pcall(require, "luasnip") then
    local ok = pcall(vim.cmd, "LuaSnipListAvailable")
    if not ok then
      vim.notify("Trigger snippet via completion", vim.log.levels.INFO)
    end
  else
    vim.notify("No snippet engine bound; use completion", vim.log.levels.INFO)
  end
end, { desc = "Snippet" })
map("n", "<Leader>ie", function()
  vim.ui.input({ prompt = "Emoji / text: " }, function(s)
    if s and s ~= "" then
      vim.api.nvim_put({ s }, "c", true, true)
    end
  end)
end, { desc = "Emoji" })
map("n", "<Leader>ip", function()
  local path = vim.fn.expand("%:p:h")
  vim.fn.setreg(":", path)
  vim.notify("Path in cmdline register: " .. path, vim.log.levels.INFO)
end, { desc = "Evil ex path" })

-- ---------- notes (SPC n) — markdown 近似 Org notes ----------
map("n", "<Leader>nn", function()
  local path = vim.fn.stdpath("data") .. "/doom-capture.md"
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  local stamp = os.date("%Y-%m-%d %H:%M")
  vim.api.nvim_buf_set_lines(0, -1, -1, false, { "", "## " .. stamp, "" })
  vim.cmd("normal! G")
end, { desc = "Org capture" })
map("n", "<Leader>nN", function()
  vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.stdpath("data") .. "/doom-capture.md"))
end, { desc = "Goto capture" })
map("n", "<Leader>na", function()
  vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.stdpath("data") .. "/doom-capture.md"))
end, { desc = "Org agenda" })
map("n", "<Leader>nf", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.files({ cwd = notes_dir() })
  end
end, { desc = "Find file in notes" })
map("n", "<Leader>nF", function()
  vim.cmd("edit " .. vim.fn.fnameescape(notes_dir()))
end, { desc = "Browse notes" })
map("n", "<Leader>ns", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.grep({ cwd = notes_dir() })
  end
end, { desc = "Search notes" })
map("n", "<Leader>n*", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.grep({ cwd = notes_dir(), search = vim.fn.expand("<cword>") })
  end
end, { desc = "Search notes for symbol" })
map("n", "<Leader>nt", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.grep({ cwd = notes_dir(), search = "TODO|FIXME|\\[ \\]" })
  end
end, { desc = "Todo list" })
map("n", "<Leader>nl", function()
  local path = vim.fn.expand("%:p")
  local link = string.format("[[file:%s][%s]]", path, vim.fn.expand("%:t"))
  vim.fn.setreg("+", link)
  vim.notify("Stored link: " .. link, vim.log.levels.INFO)
end, { desc = "Org store link" })

-- ---------- workspace (SPC TAB) ≈ Neovim tabpages ----------
map("n", "<Leader><Tab><Tab>", "<cmd>tabs<cr>", { desc = "Display tab bar" })
map("n", "<Leader><Tab>.", "<cmd>tabs<cr>", { desc = "Switch workspace" })
map("n", "<Leader><Tab>`", "<cmd>tabnext #<cr>", { desc = "Switch to last workspace" })
map("n", "<Leader><Tab>n", "<cmd>tabnew<cr>", { desc = "New workspace" })
map("n", "<Leader><Tab>N", function()
  vim.ui.input({ prompt = "Tab name: " }, function(name)
    vim.cmd("tabnew")
    if name and name ~= "" then
      -- tab name via tabline variable if supported
      pcall(vim.api.nvim_tabpage_set_var, 0, "name", name)
      vim.notify("Workspace: " .. name, vim.log.levels.INFO)
    end
  end)
end, { desc = "New named workspace" })
map("n", "<Leader><Tab>d", "<cmd>tabclose<cr>", { desc = "Kill this workspace" })
map("n", "<Leader><Tab>D", "<cmd>tabonly<cr>", { desc = "Delete saved workspace" })
map("n", "<Leader><Tab>]", "<cmd>tabnext<cr>", { desc = "Next workspace" })
map("n", "<Leader><Tab>[", "<cmd>tabprevious<cr>", { desc = "Previous workspace" })
map("n", "<Leader><Tab>r", function()
  vim.ui.input({ prompt = "Rename tab: " }, function(name)
    if name and name ~= "" then
      pcall(vim.api.nvim_tabpage_set_var, 0, "name", name)
    end
  end)
end, { desc = "Rename workspace" })
map("n", "<Leader><Tab>s", function()
  local path = vim.fn.stdpath("state") .. "/doom-workspace.vim"
  vim.cmd("mksession! " .. vim.fn.fnameescape(path))
  vim.notify("Workspace session saved", vim.log.levels.INFO)
end, { desc = "Save workspace to file" })
map("n", "<Leader><Tab>l", function()
  local path = vim.fn.stdpath("state") .. "/doom-workspace.vim"
  if vim.fn.filereadable(path) == 1 then
    vim.cmd("source " .. vim.fn.fnameescape(path))
  else
    vim.notify("No workspace session", vim.log.levels.WARN)
  end
end, { desc = "Load workspace from file" })
map("n", "<Leader><Tab>x", "<cmd>tabonly|tabnew|tabonly<cr>", { desc = "Kill session" })
map("n", "<Leader><Tab>R", function()
  local path = vim.fn.stdpath("state") .. "/doom-session.vim"
  if vim.fn.filereadable(path) == 1 then
    vim.cmd("source " .. vim.fn.fnameescape(path))
  end
end, { desc = "Restore last session" })
map("n", "<Leader><Tab>1", "<cmd>tabnext 1<cr>", { desc = "Switch to 1st workspace" })
map("n", "<Leader><Tab>2", "<cmd>tabnext 2<cr>", { desc = "Switch to 2nd workspace" })
map("n", "<Leader><Tab>3", "<cmd>tabnext 3<cr>", { desc = "Switch to 3rd workspace" })
map("n", "<Leader><Tab>4", "<cmd>tabnext 4<cr>", { desc = "Switch to 4th workspace" })
map("n", "<Leader><Tab>5", "<cmd>tabnext 5<cr>", { desc = "Switch to 5th workspace" })
map("n", "<Leader><Tab>6", "<cmd>tabnext 6<cr>", { desc = "Switch to 6th workspace" })
map("n", "<Leader><Tab>7", "<cmd>tabnext 7<cr>", { desc = "Switch to 7th workspace" })
map("n", "<Leader><Tab>8", "<cmd>tabnext 8<cr>", { desc = "Switch to 8th workspace" })
map("n", "<Leader><Tab>9", "<cmd>tabnext 9<cr>", { desc = "Switch to 9th workspace" })
map("n", "<Leader><Tab>0", "<cmd>tablast<cr>", { desc = "Switch to final workspace" })

-- ============================================================================
-- Batch 6: 剩余可映射项（project extras / search links / git remote / open）
-- ============================================================================

local function projects_file()
  return vim.fn.stdpath("state") .. "/doom-known-projects.txt"
end

local function read_projects()
  local path = projects_file()
  if vim.fn.filereadable(path) ~= 1 then
    return {}
  end
  return vim.fn.readfile(path)
end

local function write_projects(list)
  vim.fn.writefile(list, projects_file())
end

local function git_remote_https()
  local url = vim.fn.systemlist("git config --get remote.origin.url")[1] or ""
  url = url:gsub("^git@", "https://"):gsub(":", "/"):gsub("%.git$", ""):gsub("https///", "https://")
  return url
end

-- project extras
map("n", "<Leader>p>", function()
  vim.ui.input({ prompt = "Browse other project: ", default = vim.fn.expand("~") }, function(dir)
    if dir and dir ~= "" then
      vim.cmd("cd " .. vim.fn.fnameescape(dir))
      vim.cmd("edit " .. vim.fn.fnameescape(dir))
    end
  end)
end, { desc = "Browse other project" })
map("n", "<Leader>pa", function()
  local root = vim.fn.getcwd()
  local list = read_projects()
  for _, p in ipairs(list) do
    if p == root then
      vim.notify("Already known: " .. root, vim.log.levels.INFO)
      return
    end
  end
  table.insert(list, root)
  write_projects(list)
  vim.notify("Added project: " .. root, vim.log.levels.INFO)
end, { desc = "Add new project" })
map("n", "<Leader>pd", function()
  local root = vim.fn.getcwd()
  local list = vim.tbl_filter(function(p)
    return p ~= root
  end, read_projects())
  write_projects(list)
  vim.notify("Removed project: " .. root, vim.log.levels.INFO)
end, { desc = "Remove known project" })
map("n", "<Leader>pD", function()
  vim.ui.input({ prompt = "Discover under: ", default = vim.fn.expand("~/src") }, function(dir)
    if not dir or dir == "" then
      return
    end
    local found = vim.fn.systemlist({ "find", dir, "-maxdepth", "3", "-name", ".git", "-type", "d" })
    local list = read_projects()
    local set = {}
    for _, p in ipairs(list) do
      set[p] = true
    end
    local n = 0
    for _, g in ipairs(found) do
      local root = vim.fn.fnamemodify(g, ":h")
      if not set[root] then
        table.insert(list, root)
        n = n + 1
      end
    end
    write_projects(list)
    vim.notify("Discovered " .. n .. " projects", vim.log.levels.INFO)
  end)
end, { desc = "Discover projects in folder" })
map("n", "<Leader>pC", function()
  local cmd = vim.g._doom_last_project_cmd
  if not cmd then
    vim.notify("No last project command", vim.log.levels.WARN)
    return
  end
  vim.cmd("!" .. cmd)
end, { desc = "Repeat last command" })
map("n", "<Leader>pe", function()
  for _, name in ipairs({ ".nvim.lua", ".editorconfig", ".dir-locals.el", "Makefile" }) do
    local p = vim.fn.getcwd() .. "/" .. name
    if vim.fn.filereadable(p) == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(p))
      return
    end
  end
  vim.notify("No project local config found", vim.log.levels.WARN)
end, { desc = "Edit project .dir-locals" })
map("n", "<Leader>pg", function()
  for _, name in ipairs({ "Makefile", "package.json", "Cargo.toml", "go.mod", "pyproject.toml" }) do
    local p = vim.fn.getcwd() .. "/" .. name
    if vim.fn.filereadable(p) == 1 then
      vim.cmd("edit " .. vim.fn.fnameescape(p))
      return
    end
  end
  vim.notify("No configure file found", vim.log.levels.WARN)
end, { desc = "Configure project" })
map("n", "<Leader>pi", function()
  vim.notify("Project cache invalidated (noop without projectile)", vim.log.levels.INFO)
end, { desc = "Invalidate project cache" })
map("n", "<Leader>po", function()
  local file = vim.fn.expand("%:p")
  if file == "" then
    return
  end
  local alts = {
    [".c"] = ".h",
    [".h"] = ".c",
    [".cpp"] = ".hpp",
    [".hpp"] = ".cpp",
    [".ts"] = ".js",
    [".js"] = ".ts",
    [".tsx"] = ".jsx",
    [".jsx"] = ".tsx",
  }
  local ext = file:match("(%.[^%.]+)$")
  local alt = ext and alts[ext]
  if not alt then
    vim.notify("No sibling mapping for " .. tostring(ext), vim.log.levels.WARN)
    return
  end
  local sibling = file:gsub(ext .. "$", alt)
  if vim.fn.filereadable(sibling) == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(sibling))
  else
    vim.notify("Sibling not found: " .. sibling, vim.log.levels.WARN)
  end
end, { desc = "Find sibling file" })
map("n", "<Leader>pR", function()
  vim.ui.input({ prompt = "Run project: ", default = "make run" }, function(cmd)
    if cmd and cmd ~= "" then
      vim.g._doom_last_project_cmd = cmd
      vim.cmd("!" .. cmd)
    end
  end)
end, { desc = "Run project" })
map("n", "<Leader>pT", function()
  vim.ui.input({ prompt = "Test project: ", default = "make test" }, function(cmd)
    if cmd and cmd ~= "" then
      vim.g._doom_last_project_cmd = cmd
      vim.cmd("!" .. cmd)
    end
  end)
end, { desc = "Test project" })

-- search leftovers
map("n", "<Leader>sl", function()
  vim.cmd("normal! gx")
end, { desc = "Jump to visible link" })
map("n", "<Leader>sL", function()
  local word = vim.fn.expand("<cfile>")
  if word ~= "" and vim.fn.filereadable(word) == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(word))
  else
    local ok, fzf = pcall(require, "fzf-lua")
    if ok then
      fzf.files({ query = word })
    end
  end
end, { desc = "Jump to link" })
map("n", "<Leader>sk", fzf_lua("help_tags"), { desc = "Look up in local docsets" })
map("n", "<Leader>sK", fzf_lua("help_tags"), { desc = "Look up in all docsets" })
map("n", "<Leader>st", function()
  local w = vim.fn.expand("<cword>")
  vim.fn.jobstart({ "open", "https://duckduckgo.com/?q=define+" .. vim.fn.escape(w, " ") }, { detach = true })
end, { desc = "Dictionary" })
map("n", "<Leader>sT", function()
  local w = vim.fn.expand("<cword>")
  vim.fn.jobstart({ "open", "https://duckduckgo.com/?q=synonym+" .. vim.fn.escape(w, " ") }, { detach = true })
end, { desc = "Thesaurus" })

-- git remote / clone extras
map("n", "<Leader>gY", function()
  local url = git_remote_https()
  if url == "" then
    vim.notify("No remote", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", url)
  vim.notify("Yanked homepage: " .. url, vim.log.levels.INFO)
end, { desc = "Copy link to homepage" })
map("n", "<Leader>go", function()
  local url = git_remote_https()
  local file = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
  local line = vim.fn.line(".")
  if url ~= "" then
    local full = string.format("%s/blob/HEAD/%s#L%d", url, file, line)
    vim.fn.jobstart({ "open", full }, { detach = true })
  end
end, { desc = "Browse file or region" })
map("n", "<Leader>gh", function()
  local url = git_remote_https()
  if url ~= "" then
    vim.fn.jobstart({ "open", url }, { detach = true })
  end
end, { desc = "Browse homepage" })
map("n", "<Leader>gC", function()
  vim.ui.input({ prompt = "git clone URL: " }, function(url)
    if url and url ~= "" then
      vim.fn.jobstart({ "git", "clone", url }, { detach = true })
      vim.notify("Cloning " .. url, vim.log.levels.INFO)
    end
  end)
end, { desc = "Magit clone" })
map("n", "<Leader>gD", function()
  local file = vim.fn.expand("%:p")
  if file == "" then
    return
  end
  vim.fn.system({ "git", "rm", "-f", "--", file })
  vim.cmd("bdelete!")
  vim.notify("git rm " .. file, vim.log.levels.INFO)
end, { desc = "Magit file delete" })
map("n", "<Leader>g/", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf.git_status then
    fzf.git_status()
  end
end, { desc = "Magit dispatch" })
map("n", "<Leader>g.", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok and fzf.git_bcommits then
    fzf.git_bcommits()
  end
end, { desc = "Magit file dispatch" })

-- open leftovers
map("n", "<Leader>o/", "<cmd>Oil<cr>", { desc = "Open directory (oil)" })
map("n", "<Leader>od", function()
  vim.notify("Debugger: install nvim-dap to enable", vim.log.levels.INFO)
end, { desc = "Start debugger" })
map("n", "<Leader>om", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.grep({ cwd = notes_dir(), search = ":" })
  end
end, { desc = "Tags search" })
map("n", "<Leader>ov", function()
  local ok, fzf = pcall(require, "fzf-lua")
  if ok then
    fzf.grep({ cwd = notes_dir() })
  end
end, { desc = "View search" })
map("n", "<Leader>bI", fzf_lua("buffers"), { desc = "ibuffer workspace" })

-- ============================================================================
-- 折叠 (Evil z) - 使用Vim原生折叠命令
-- ============================================================================
map("n", "za", "za", { desc = "Toggle fold" })
map("n", "zc", "zc", { desc = "Close fold" })
map("n", "zr", "zr", { desc = "Open all folds" })
map("n", "zm", "zm", { desc = "Close all folds" })

-- ============================================================================
-- 列表/补全内操作 (使用Telescope默认键位)
-- ============================================================================
-- 已在Telescope映射中设置

-- 传统Vim快捷键保留
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", function()
  local ok, builtin = pcall(require, "telescope.builtin")
  if ok then
    builtin.lsp_references()
  else
    vim.lsp.buf.references()
  end
end, { desc = "Find references with preview" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "Show documentation" })

map("n", "<Leader>an", function()
  local ok, annotate = pcall(require, "annotate")
  if ok then
    annotate.create_annotation()
  else
    vim.notify("annotate.nvim not available", vim.log.levels.WARN)
  end
end, { desc = "Annotation: add/edit (float)" })

map("n", "<Leader>aN", function()
  local ok, annotate = pcall(require, "annotate")
  if ok then
    annotate.delete_annotation()
  else
    vim.notify("annotate.nvim not available", vim.log.levels.WARN)
  end
end, { desc = "Annotation: delete" })

-- 插件管理快捷键保留
map("n", "<Leader>uu", function() vim.cmd("Lazy update") end, { desc = "Update all plugins" })
map("n", "<Leader>uc", function() vim.cmd("Lazy check") end, { desc = "Check for updates" })
map("n", "<Leader>us", function() vim.cmd("Lazy sync") end, { desc = "Sync plugins" })
map("n", "<Leader>uh", function() vim.cmd("Lazy home") end, { desc = "Open Lazy home" })
map("n", "<Leader>ul", function() vim.cmd("Lazy clean") end, { desc = "Clean unused plugins" })
map("n", "<Leader>ui", function() vim.cmd("Lazy install") end, { desc = "Install missing plugins" })

-- 复制粘贴（不用 SPC p，避免与 Doom +project 冲突）
map("v", "<Leader>y", '"+y', { desc = "Yank to system clipboard" })
map("n", "<Leader>yy", '"+yy', { desc = "Yank line to system clipboard" })
map("n", "<Leader>yp", '"+p', { desc = "Paste from system clipboard" })
map("n", "<Leader>yP", '"+P', { desc = "Paste before cursor from system clipboard" })
map("v", "<Leader>yp", '"+p', { desc = "Paste from system clipboard" })
map("n", "<Leader>ya", 'gg"+yG', { desc = "Yank entire file to clipboard" })

-- 字体大小调整保留
if vim.fn.has("gui_running") == 1 then
  map("n", "<Leader>=", function()
    local current_font = vim.opt.guifont:get()[1] or "PTMono-Regular:h12"
    local size = current_font:match("h(%d+)") or 12
    local new_size = math.min(tonumber(size) + 1, 24)  -- 最大 24
    local new_font = current_font:gsub("h%d+", "h" .. new_size)
    vim.opt.guifont = new_font
    vim.notify("Font size: " .. new_size, vim.log.levels.INFO)
  end, { desc = "Increase font size" })

  map("n", "<Leader>-", function()
    local current_font = vim.opt.guifont:get()[1] or "PTMono-Regular:h12"
    local size = current_font:match("h(%d+)") or 12
    local new_size = math.max(tonumber(size) - 1, 8)  -- 最小 8
    local new_font = current_font:gsub("h%d+", "h" .. new_size)
    vim.opt.guifont = new_font
    vim.notify("Font size: " .. new_size, vim.log.levels.INFO)
  end, { desc = "Decrease font size" })
end
