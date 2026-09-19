# Doom Emacs → Neovim keymap parity (full export + batches)

## Goal

Export Doom’s leader key table, compare with Neovim, then replicate in batches with nvim-equivalent actions.

## Approach

- Primary: static parse of Doom `map!` sources
- Secondary later: runtime dump from Doom for validation
- Do **not** replace config with a doom-nvim distro

## Sources

| Source | Role |
|--------|------|
| `~/.config/emacs/modules/config/default/+evil-bindings.el` | Main SPC map (~387) |
| `~/.config/doom/init.el` | Enabled modules (filter `:when modulep!`) |
| Extra module `map! :leader` under `modules/` | Module-specific (phase 0.1) |
| `~/.config/nvim/lua/core/keymaps*.lua` | Current nvim maps |

## Status values

| Status | Meaning |
|--------|---------|
| `done` | Same keys + equivalent action |
| `partial` | Keys exist, behavior differs |
| `todo` | Missing; can map to nvim |
| `n/a` | Emacs-only; skip |

## Deliverables

| Artifact | Purpose |
|----------|---------|
| `scripts/export-doom-keymaps.py` | Re-runnable export + parity |
| `docs/doom-keymap-parity.md` | Full comparison table |
| `lua/core/keymaps*.lua` | Batched binding updates |

## Batches (after phase 0)

1. SPC root (`. , / * SPC RET TAB …`)
2. `b` / `f` / `w` / `p`
3. `s` / `g` / `c`
4. `t` / `o` / `q`
5. `i` / `n` / `TAB` workspace (approx)
6. Remainder + `n/a` cleanup

## Principles

- Prefer 1:1 keys; nvim tools for actions (fzf-lua, gitsigns, lsp, …)
- Keep opencode / pi / annotate extras
- Mark impossible bindings `n/a`, do not fake them

## Easy mistakes

- Parsing must track `:prefix-map` nesting or keys will be wrong
- `:when (modulep! …)` — only include if module enabled in user’s `init.el`
- `<leader>p` paste vs `+project` collision already present in nvim — document, don’t silently drop Doom `p`
