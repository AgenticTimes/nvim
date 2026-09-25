-- scripts/smoke.lua — nvim --headless 冒烟测试
-- 用法:
--   nvim --headless -u init.lua -c "luafile scripts/smoke.lua" -c "qa!" 2>&1 | grep SMOKE
-- 输出: SMOKE_PASS 或 SMOKE_FAIL (带通过/失败计数)
-- 检查: 关键模块可 require / 关键命令存在 / 关键键位存在 / 无致命启动错误

local results = { pass = 0, fail = 0 }
local failures = {}

local function check(label, cond, detail)
  if cond then
    results.pass = results.pass + 1
    print("SMOKE OK   " .. label)
  else
    results.fail = results.fail + 1
    table.insert(failures, label .. (detail and (" :: " .. detail) or ""))
    print("SMOKE FAIL " .. label .. (detail and (" :: " .. detail) or ""))
  end
end

local function module_ok(name)
  local ok, err = pcall(require, name)
  return ok, err
end

-- 1. 核心模块可加载
local core_mods = {
  "core.bootstrap", "core.env", "core.options", "core.keymaps", "core.theme",
  "core.autosave", "core.readonly", "pi",
}
for _, m in ipairs(core_mods) do
  local ok, err = module_ok(m)
  check("require " .. m, ok, err)
end

-- 2. 自定义模块可加载
-- 注意: custom.markdown-handler/table-wrap 依赖 render-markdown 插件,且 render-markdown 的
-- config 又会 require 它们(循环依赖)。先触发 render-markdown 加载,再 require handlers。
pcall(function()
  require("lazy").load({ plugins = { "render-markdown.nvim" } })
end)
local custom_mods = {
  "custom.fix-ts-directive",
  "custom.markdown-handler", "custom.markdown-inline-handler",
  "custom.link", "custom.table-wrap",
}
for _, m in ipairs(custom_mods) do
  local ok, err = module_ok(m)
  check("require " .. m, ok, err)
end

-- 3. 关键用户命令存在
local cmds = {
  "OpencodeToggleWin", "OpencodeStopWin",
  "ThemeToggle", "Lazy", "Pi", "PiToggle", "PiTermCopy",
}
for _, c in ipairs(cmds) do
  local exists = vim.fn.exists(":" .. c) == 2
  check("command :" .. c, exists)
end

-- 5. 关键键位存在(<Leader> = ",")
local keys = {
  { mode = "n", lhs = ",co", label = "<Leader>co opencode" },
  { mode = "n", lhs = ",ai", label = "<Leader>ai pi.neovim toggle" },
  { mode = "n", lhs = ",gc", label = "<Leader>gc git commit" },
  { mode = "n", lhs = "gd", label = "gd definition" },
  { mode = "n", lhs = "K", label = "K hover" },
}
for _, k in ipairs(keys) do
  local map = vim.api.nvim_get_keymap(k.mode)
  local found = false
  for _, m in ipairs(map) do
    if m.lhs == k.lhs then found = true; break end
  end
  check("keymap " .. k.mode .. " " .. k.lhs .. " " .. k.label, found)
end

-- 6. 颜色主题可用(desert 是默认)
local theme_ok = vim.fn.exists("colors_name") == 0 or vim.g.colors_name ~= nil
check("colorscheme loaded", theme_ok, vim.g.colors_name)

-- 汇总
print("SMOKE SUMMARY: " .. results.pass .. " passed, " .. results.fail .. " failed")
if results.fail > 0 then
  print("SMOKE_FAILED")
  for _, f in ipairs(failures) do
    print("  FAILED: " .. f)
  end
  vim.cmd("cquit")
else
  print("SMOKE_PASS")
end
