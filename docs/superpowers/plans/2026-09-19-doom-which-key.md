# Doom-style which-key Implementation Plan

> **For agentic workers:** Execute task-by-task. Steps use checkbox syntax.

**Goal:** Make Neovim which-key look like Doom Emacs (bottom bar, `KEY : desc`, `+group` names).

**Architecture:** Reconfigure `folke/which-key.nvim` with `preset = "classic"` and register leader group labels via `which-key.add`. No keymap behavior changes.

**Tech Stack:** Neovim Lua, which-key.nvim v3

## Global Constraints

- Do not change bindings in `lua/core/keymaps*.lua`
- Group names without leading `+` (plugin adds it)
- Remove floating `rounded` / fixed width overrides

---

### Task 1: Doom which-key setup + groups

**Files:**
- Modify: `lua/plugins/editor.lua` (which-key plugin block only)

- [x] **Step 1:** Replace which-key `setup({...})` with classic preset + Doom formatting
- [x] **Step 2:** After setup, `require("which-key").add({...})` for group labels from the design spec
- [ ] **Step 3:** Manual verify: restart nvim, press `SPC`, confirm bottom bar + `+file` / ` : `

**Done when:** `SPC` shows Doom-like panel; entering `f` lists file keys with colon separators.
