# Doom Keymap Parity Implementation Plan

> **For agentic workers:** Execute task-by-task. Steps use checkbox syntax.

**Goal:** Export Doom leader bindings, build a parity table vs Neovim, then replicate in batches.

**Architecture:** Python static parser over Doom `map!` + nvim Lua keymap scan → markdown report → batch edits to `lua/core/keymaps*.lua`.

**Tech Stack:** Python 3, Doom Emacs elisp sources, Neovim Lua keymaps

## Global Constraints

- Phase 0 produces docs only (no binding changes until batches start)
- Status: `done` | `partial` | `todo` | `n/a`
- Preserve opencode/pi/annotate keys

---

### Task 1: Export script + parity doc (phase 0)

**Files:**
- Create: `scripts/export-doom-keymaps.py`
- Create: `docs/doom-keymap-parity.md` (generated)

- [x] Parse `+evil-bindings.el` leader section with prefix-map stack
- [x] Parse enabled modules from `~/.config/doom/init.el`
- [x] Scan nvim `<Leader>` maps under `lua/core/keymaps*.lua`
- [x] Write `docs/doom-keymap-parity.md` with summary counts + full table
- [x] Run script once; verify ≥300 Doom rows and non-zero nvim matches

**Done when:** `python3 scripts/export-doom-keymaps.py` regenerates the doc; summary shows done/partial/todo/n/a counts.

### Task 1b: Batch 1 — SPC root menu

**Files:**
- Modify: `lua/core/keymaps.lua`
- Modify: `lua/plugins/editor.lua` (help group)
- Regenerate: `docs/doom-keymap-parity.md`

- [x] Add Doom root bindings (`; : x X ~ . , < \` ' * / SPC RET`)
- [x] Keep `SPC u*` as plugins (universal-arg conflict)
- [x] Add `SPC h` help starters (`hh`, `hk`)
- [x] Re-run export; verify root rows mostly `done`

### Task 1c: Batch 2 — b / f / w / p

**Files:**
- Modify: `lua/core/keymaps.lua`
- Regenerate: `docs/doom-keymap-parity.md`

- [x] Expand file/buffer/window/project to Doom keys
- [x] Move clipboard paste `SPC p` → `SPC yp` (project prefix)
- [x] Re-run export (done↑ ~24→74)

### Task 1d: Batch 3 — s / g / c

**Files:**
- Modify: `lua/core/keymaps.lua`
- Regenerate: `docs/doom-keymap-parity.md`

- [x] Align search to Doom (`ss` buffer, `sp` project, `sr` marks, …)
- [x] Align code LSP keys (`ca/cr/cd/…`); keep `co` for opencode
- [x] Align git via gitsigns + fzf-lua (no Magit/Forge)

### Task 1e: Batch 4 — t / o / q

**Files:**
- Modify: `lua/core/keymaps.lua`
- Regenerate: `docs/doom-keymap-parity.md`

- [x] Expand toggle / open / quit-session
- [x] Session save/load via mksession
- [x] Re-run export (done↑ ~123→155)

### Task 1f: Batch 5 — i / n / TAB

**Files:**
- Modify: `lua/core/keymaps.lua`, `lua/plugins/editor.lua`
- Regenerate: `docs/doom-keymap-parity.md`

- [x] Insert prefix (`if/iF/iu/iy/ir/is/ie`)
- [x] Notes approx via `stdpath("data")/doom-notes` + capture
- [x] Workspace ≈ tabpages under `SPC TAB …`
- [x] Move last-buffer off `SPC TAB` (keep `SPC \``)

### Task 1g: Batch 6 — remainder

**Files:**
- Modify: `lua/core/keymaps.lua`, `scripts/export-doom-keymaps.py`
- Regenerate: `docs/doom-keymap-parity.md`

- [x] Project extras (known-projects list, sibling, run/test, …)
- [x] Search links / dictionary web lookup
- [x] Git remote browse / clone / delete approx
- [x] Classifier: prefix-only + Magit/Forge/macos-app → `n/a`
- [x] **todo = 0** (done 228 / partial 24 / n/a 135)

---

### Task 2–7: Binding batches (later)

Deferred until phase 0 table reviewed. Each batch updates keymaps + re-runs export.
