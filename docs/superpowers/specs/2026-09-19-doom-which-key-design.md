# Doom-style which-key for Neovim

## Goal

Make `<Leader>` (SPC) hints look like Doom Emacs which-key: bottom full-width multi-column panel, `KEY : description`, groups as `+name`.

## Scope

- **In:** `which-key.nvim` visual config + explicit group labels for existing leader prefixes
- **Out:** Changing actual keybindings; replacing legendary (`SPC ?`)

## Approach

Config + `which-key.add` group specs (no new plugin).

## Files

| File | Change |
|------|--------|
| `lua/plugins/editor.lua` | Doom-style which-key setup + register groups |

## which-key config (easy to get wrong)

- `preset = "classic"` — bottom bar, no border; **remove** current `rounded` / fixed `width = 50` (those force a floating panel)
- `icons.separator = " : "`
- `icons.mappings = false` — no per-mapping icons
- `icons.group = "+"` — groups show as `+file`
- Key replace: `<Space>`→`SPC`, `<CR>`→`RET`, `<Tab>`→`TAB`, `<Esc>`→`ESC`
- Group `group` values must be **without** leading `+` (plugin prepends it; `replace.desc` also strips `^+`)

## Group map (existing prefixes)

| Prefix | Group label |
|--------|-------------|
| `SPC f` | file |
| `SPC b` | buffer |
| `SPC w` | window |
| `SPC p` | project |
| `SPC s` | search |
| `SPC g` | git |
| `SPC c` | code |
| `SPC q` | quit/session |
| `SPC t` | toggle |
| `SPC o` | open |
| `SPC a` | actions |
| `SPC u` | plugins |
| `SPC [` | previous |
| `SPC ]` | next |

Top-level single keys (`.`, `:`, `?`, `TAB`, paste `p`/`P`, yank `y`) stay as leaf entries; no group.

## Verify

1. Restart nvim (or `:Lazy reload which-key.nvim`)
2. Press `SPC`, wait for popup
3. Expect: bottom full-width columns, `SPC`/`RET` labels, `f : +file`, enter `f` → file actions with ` : ` separators
