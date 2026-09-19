-- pi.nvim 键位（本地 ~/source/pi.nvim）
local map = require("core.keymaps.util").map

--- Leave visual so '< '> marks are set, then run fn
local function from_visual(fn)
  return function()
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" or mode == "\22" then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
    end
    fn()
  end
end

map({ "n", "x" }, "<Leader>ai", from_visual(function()
  require("pi").toggle()
end), { desc = "pi: toggle chat UI" })

map({ "n", "x" }, "<Leader>aI", from_visual(function()
  require("pi.runtime").new_session()
  require("pi").toggle()
end), { desc = "pi: new session + open" })

map("n", "<Leader>ad", function()
  require("pi.review").open(1)
end, { desc = "pi: open review diff" })

map("n", "<Leader>a]", function()
  require("pi").diff_next()
end, { desc = "pi: next pending file" })

map("n", "<Leader>a[", function()
  require("pi").diff_prev()
end, { desc = "pi: prev pending file" })

map("n", "<Leader>am", function()
  require("pi.runtime").cycle_model()
end, { desc = "pi: cycle model" })

map("n", "<Leader>at", function()
  require("pi.runtime").cycle_thinking()
end, { desc = "pi: cycle thinking" })

map("n", "<Leader>aF", function()
  require("pi.ui").toggle_fullscreen()
end, { desc = "pi: toggle fullscreen UI" })

map({ "n", "x" }, "<Leader>as", from_visual(function()
  require("pi.sessions").pick()
end), { desc = "pi: pick session" })

map("n", "<Leader>aA", function()
  require("pi.review").accept_all()
end, { desc = "pi: accept all pending" })

map("n", "<Leader>aR", function()
  require("pi.review").reject_all()
end, { desc = "pi: reject all pending" })

map("n", "<Leader>ae", function()
  require("pi.ui").focus_toggle()
end, { desc = "pi: focus toggle editor ↔ UI" })

map("n", "<Leader>ac", function()
  require("pi.runtime").toggle_mode()
end, { desc = "pi: toggle chat/auto mode" })

map("n", "<Leader>an", function()
  require("pi.runtime").set_session_name()
end, { desc = "pi: name session" })

map("n", "<Leader>av", function()
  require("pi.inspect").pick()
end, { desc = "pi: inspect session" })

map("n", "<Leader>ap", function()
  require("pi.approve").cycle_mode()
end, { desc = "pi: cycle approve mode" })

map("n", "<Leader>ah", function()
  require("pi.runtime").export_html()
end, { desc = "pi: export session HTML" })
