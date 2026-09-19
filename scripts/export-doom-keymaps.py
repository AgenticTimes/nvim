#!/usr/bin/env python3
"""Export Doom leader bindings and compare with Neovim <Leader> maps.

Usage:
  python3 scripts/export-doom-keymaps.py
  python3 scripts/export-doom-keymaps.py --doom-emacs ~/.config/emacs --doom-user ~/.config/doom --nvim ~/.config/nvim
"""

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass, field
from pathlib import Path


DESC_RE = re.compile(
    r""":desc\s+"([^"]*)"\s+"([^"]*)"(?:\s+(?:#'|')?([A-Za-z0-9_/+.:!<>=-]+))?"""
)
PREFIX_MAP_RE = re.compile(r""":prefix-map\s+\("([^"]+)"\s*\.\s*"([^"]*)"\)""")
MODULEP_RE = re.compile(r"""modulep!\s+(:[^\s)]+)(?:\s+([^\s)]+))?""")
# doom! modules: optional (name +flags) or bare name, skip comments
DOOM_MODULE_RE = re.compile(
    r"""^\s*\(?\s*([a-z][a-z0-9-]*)(?:\s+\+[a-z0-9-]+)*\s*\)?\s*(?:;.*)?$""",
    re.I,
)
NVIM_LHS_RE = re.compile(r""""((?:<Leader>|<leader>)[^"]*)""")
NVIM_DESC_RE = re.compile(r"""desc\s*=\s*["']([^"']*)["']""")


def parse_nvim_leaders(nvim_root: Path) -> dict[str, str]:
    """Map normalized 'SPC b k' -> desc."""
    files = list((nvim_root / "lua" / "core").rglob("*.lua"))
    out: dict[str, str] = {}
    for f in files:
        text = f.read_text(encoding="utf-8", errors="replace")
        for m in NVIM_LHS_RE.finditer(text):
            lhs = m.group(1)
            # look ahead for desc= (multi-line map callbacks can be long)
            window = text[m.end() : m.end() + 2500]
            dm = NVIM_DESC_RE.search(window)
            if not dm:
                continue
            keys = normalize_nvim_lhs(lhs)
            out[keys] = dm.group(1)
    return out


def normalize_nvim_lhs(lhs: str) -> str:
    # Strip a single mapleader prefix, then tokenize the rest.
    s = lhs
    for prefix in ("<Leader>", "<leader>"):
        if s.startswith(prefix):
            s = s[len(prefix) :]
            break
    parts = ["SPC"]
    if s in ("",):
        return "SPC"
    # Remaining "<Leader>" / "<Space>" means another Space (Doom SPC SPC)
    if s in ("<Leader>", "<leader>", "<Space>"):
        parts.append("SPC")
        return " ".join(parts)
    i = 0
    while i < len(s):
        if s.startswith("<", i):
            j = s.find(">", i)
            if j < 0:
                parts.append(s[i:])
                break
            tag = s[i + 1 : j]
            mapping = {
                "Tab": "TAB",
                "CR": "RET",
                "Ret": "RET",
                "Esc": "ESC",
                "Space": "SPC",
                "Leader": "SPC",
                "leader": "SPC",
            }
            parts.append(mapping.get(tag, tag.upper()))
            i = j + 1
        else:
            parts.append(s[i])
            i += 1
    return " ".join(parts)


@dataclass
class Span:
    start: int
    end: int
    key: str
    name: str


@dataclass
class WhenSpan:
    start: int
    end: int
    category: str
    module: str
    flag: str | None = None  # e.g. "-eglot" or "+everywhere"
    unless: bool = False


@dataclass
class DoomBind:
    keys: str  # e.g. SPC b k
    key: str
    desc: str
    cmd: str
    prefix: str
    group: str
    modules: list[str] = field(default_factory=list)
    enabled: bool = True


def matching_paren_end(text: str, open_idx: int) -> int:
    """open_idx points at '('; return index after matching ')'."""
    depth = 0
    i = open_idx
    n = len(text)
    in_str = False
    while i < n:
        c = text[i]
        if in_str:
            if c == "\\" and i + 1 < n:
                i += 2
                continue
            if c == '"':
                in_str = False
            i += 1
            continue
        if c == '"':
            in_str = True
            i += 1
            continue
        if c == ";":
            # line comment
            while i < n and text[i] != "\n":
                i += 1
            continue
        if c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 0:
                return i + 1
        i += 1
    return n


def find_leader_map(text: str) -> tuple[int, int]:
    m = re.search(r"\(map!\s*:leader\b", text)
    if not m:
        raise SystemExit("could not find (map! :leader in Doom bindings")
    start = m.start()
    end = matching_paren_end(text, start)
    return start, end


def collect_prefix_spans(chunk: str, base: int) -> list[Span]:
    spans: list[Span] = []
    for m in PREFIX_MAP_RE.finditer(chunk):
        # find '(' that starts the (:prefix-map ...) form — walk back
        j = m.start()
        while j > 0 and chunk[j] != "(":
            j -= 1
        end = matching_paren_end(chunk, j)
        spans.append(Span(base + j, base + end, m.group(1), m.group(2)))
    return spans


def collect_when_spans(chunk: str, base: int) -> list[WhenSpan]:
    spans: list[WhenSpan] = []
    for kind in ("when", "unless"):
        for m in re.finditer(rf"\(\s*:{kind}\b", chunk):
            end = matching_paren_end(chunk, m.start())
            body = chunk[m.start() : end]
            mp = MODULEP_RE.search(body)
            if not mp:
                continue
            category = mp.group(1)  # :ui
            rest = mp.group(2) or ""
            # module name may be next token like workspaces or lsp
            # modulep! forms: (modulep! :ui workspaces) or (modulep! :tools lsp -eglot)
            tokens = re.findall(r"[^\s()]+", body[body.find("modulep!") :])
            # tokens[0]=modulep! tokens[1]=:cat tokens[2]=module ...
            module = tokens[2] if len(tokens) > 2 else ""
            flag = tokens[3] if len(tokens) > 3 else None
            spans.append(
                WhenSpan(
                    base + m.start(),
                    base + end,
                    category=category,
                    module=module,
                    flag=flag,
                    unless=(kind == "unless"),
                )
            )
    return spans


def active_prefixes(spans: list[Span], pos: int) -> list[Span]:
    return [s for s in spans if s.start <= pos < s.end]


def active_whens(spans: list[WhenSpan], pos: int) -> list[WhenSpan]:
    return [s for s in spans if s.start <= pos < s.end]


def parse_enabled_modules(init_el: Path) -> set[tuple[str, str]]:
    """Return set of (category, module) enabled in doom! block."""
    text = init_el.read_text(encoding="utf-8", errors="replace")
    m = re.search(r"\(doom!\s*", text)
    if not m:
        return set()
    end = matching_paren_end(text, m.start())
    block = text[m.start() : end]
    enabled: set[tuple[str, str]] = set()
    category = ""
    for line in block.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith(";;"):
            continue
        # category header :ui
        cm = re.match(r"^:([a-z]+)\s*$", stripped)
        if cm:
            category = cm.group(1)
            continue
        # (:if ...) skip complex — treat macos as os/macos if present
        if stripped.startswith("(:if"):
            if "macos" in stripped:
                enabled.add(("os", "macos"))
            continue
        # (name +flags) or name
        mm = re.match(r"^\(?\s*([a-z][a-z0-9-]*)", stripped)
        if mm and category:
            enabled.add((category, mm.group(1)))
    # default module always on when listed
    return enabled


def module_enabled(enabled: set[tuple[str, str]], whens: list[WhenSpan]) -> bool:
    if not whens:
        return True
    for w in whens:
        cat = w.category.lstrip(":")
        mod = w.module
        on = (cat, mod) in enabled
        # flag like -eglot means "lsp without eglot" — treat as enabled if module on
        if w.unless:
            if on:
                return False
        else:
            if not on:
                return False
    return True


def parse_doom_leader(
    bindings_el: Path, enabled: set[tuple[str, str]]
) -> list[DoomBind]:
    text = bindings_el.read_text(encoding="utf-8", errors="replace")
    start, end = find_leader_map(text)
    chunk = text[start:end]
    prefixes = collect_prefix_spans(chunk, start)
    whens = collect_when_spans(chunk, start)

    binds: list[DoomBind] = []
    for m in DESC_RE.finditer(chunk):
        abs_pos = start + m.start()
        desc, key, cmd = m.group(1), m.group(2), m.group(3) or ""
        prefs = active_prefixes(prefixes, abs_pos)
        wlist = active_whens(whens, abs_pos)
        prefix_keys = "".join(p.key for p in prefs)
        group = prefs[-1].name if prefs else "root"
        full = "SPC " + (" ".join(list(prefix_keys) + [key]) if prefix_keys else key)
        # prettier: SPC b k style with spaces between prefix chars that are multi
        parts = ["SPC"]
        for p in prefs:
            parts.append(p.key)
        parts.append(key)
        full = " ".join(parts)
        mods = [f"{w.category} {w.module}" for w in wlist]
        en = module_enabled(enabled, wlist)
        binds.append(
            DoomBind(
                keys=full,
                key=key,
                desc=desc,
                cmd=cmd,
                prefix=prefix_keys,
                group=group,
                modules=mods,
                enabled=en,
            )
        )
    return binds


# Heuristic: Emacs-only command prefixes / names
NA_PATTERNS = re.compile(
    r"""^(org-|doom/|magit|persp-|ivy-|helm-|vertico-|consult-|
         \+workspace/|\+popup/|\+ibuffer|\+eval/|\+format/|\+lookup/|
         \+default/|\+evil/|evil-|evil-goggles|\+org|bookmark-|ibuffer|projectile-|
         lsp-|eglot-|flycheck|flyspell|forge-|git-timemachine|
         \+macos/send-to-transmit|\+macos/send-project-to-transmit|
         \+macos/send-to-launchbar|\+macos/send-project-to-launchbar|
         org-tree-slide|org-pomodoro|dirvish|emoji-search|emojify)""",
    re.X | re.I,
)

# Prefix-only Doom entries (keymap objects, not leaf commands)
PREFIX_ONLY = {"SPC w": "SPC w ", "SPC h": "SPC h "}


def classify(bind: DoomBind, nvim: dict[str, str]) -> str:
    if not bind.enabled:
        return "n/a"  # disabled by module — still show but n/a for parity focus
    if bind.keys in nvim:
        nd = nvim[bind.keys].lower()
        dd = bind.desc.lower()
        # rough similarity
        if nd == dd or nd in dd or dd in nd:
            return "done"
        return "partial"
    # Prefix maps: done if any child binding exists
    if bind.keys in PREFIX_ONLY:
        prefix = PREFIX_ONLY[bind.keys]
        if any(k.startswith(prefix) for k in nvim):
            return "done"
    # Intentionally not mapped (conflicts with nvim Lazy under SPC u)
    if bind.keys == "SPC u" and bind.cmd == "universal-argument":
        return "n/a"
    # no nvim map
    if bind.cmd and NA_PATTERNS.search(bind.cmd):
        # still could be todo if we have equivalent — prefer todo for common ones
        common_todo = {
            "find-file",
            "switch-to-buffer",
            "kill-current-buffer",
            "projectile-find-file",
            "compile",
            "recompile",
            "basic-save-buffer",
            "evil-write-all",
            "next-buffer",
            "previous-buffer",
            "revert-buffer",
            "rename-buffer",
            "bookmark-jump",
            "execute-extended-command",
            "pp-eval-expression",
            "delete-trailing-whitespace",
        }
        if bind.cmd in common_todo:
            return "todo"
        # many doom/+ commands have nvim equivalents — mark todo if in core groups
        if bind.group in {
            "buffer",
            "file",
            "window",
            "project",
            "search",
            "git",
            "code",
            "toggle",
            "open",
            "quit",
            "root",
        }:
            # Magit/Forge/macos-app-only → n/a even in these groups
            if re.search(
                r"magit|forge-|git-timemachine|\+macos/send-|org-pomodoro|org-tree-slide|evil-goggles|dirvish",
                bind.cmd or "",
                re.I,
            ):
                return "n/a"
            return "todo"
        return "n/a"
    return "todo"


def render_markdown(
    binds: list[DoomBind], nvim: dict[str, str], out: Path
) -> dict[str, int]:
    rows = []
    counts = {"done": 0, "partial": 0, "todo": 0, "n/a": 0}
    for b in binds:
        status = classify(b, nvim)
        counts[status] = counts.get(status, 0) + 1
        nvim_desc = nvim.get(b.keys, "")
        mods = ", ".join(b.modules) if b.modules else ""
        en = "yes" if b.enabled else "no"
        rows.append(
            (
                b.keys,
                b.group,
                b.desc,
                b.cmd,
                status,
                nvim_desc,
                en,
                mods,
            )
        )

    lines = [
        "# Doom → Neovim keymap parity",
        "",
        "Generated by `scripts/export-doom-keymaps.py`. Re-run after keymap changes.",
        "",
        "## Summary",
        "",
        f"| Status | Count |",
        f"|--------|------:|",
    ]
    for k in ("done", "partial", "todo", "n/a"):
        lines.append(f"| `{k}` | {counts[k]} |")
    lines += [
        f"| **total** | {sum(counts.values())} |",
        "",
        f"Neovim `<Leader>` maps scanned: **{len(nvim)}**",
        "",
        "Remaining `partial` rows are mostly Doom **nested-prefix collisions** (same leaf key under Magit/Org-roam submaps) or intentional module forks (e.g. `SPC o t` terminal vs todo). They are not missing bindings.",
        "",
        "## Table",
        "",
        "| Keys | Group | Doom desc | Doom cmd | Status | Neovim desc | Module on | When |",
        "|------|-------|-----------|----------|--------|-------------|-----------|------|",
    ]
    def cell(s: str) -> str:
        # Avoid breaking markdown tables on | or backticks (e.g. SPC `)
        return (
            s.replace("|", "\\|")
            .replace("`", "ˋ")
        )

    for keys, group, desc, cmd, status, nd, en, mods in rows:
        lines.append(
            f"| `{cell(keys)}` | {cell(group)} | {cell(desc)} | `{cell(cmd)}` | {status} | {cell(nd)} | {en} | {cell(mods)} |"
        )
    lines.append("")
    out.write_text("\n".join(lines), encoding="utf-8")
    return counts


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--doom-emacs", type=Path, default=Path.home() / ".config/emacs")
    ap.add_argument("--doom-user", type=Path, default=Path.home() / ".config/doom")
    ap.add_argument("--nvim", type=Path, default=Path.home() / ".config/nvim")
    ap.add_argument(
        "--out",
        type=Path,
        default=None,
        help="Output markdown (default: <nvim>/docs/doom-keymap-parity.md)",
    )
    args = ap.parse_args()
    out = args.out or (args.nvim / "docs" / "doom-keymap-parity.md")

    bindings = (
        args.doom_emacs
        / "modules"
        / "config"
        / "default"
        / "+evil-bindings.el"
    )
    init_el = args.doom_user / "init.el"
    enabled = parse_enabled_modules(init_el)
    binds = parse_doom_leader(bindings, enabled)
    nvim = parse_nvim_leaders(args.nvim)
    counts = render_markdown(binds, nvim, out)
    print(f"Wrote {out}")
    print(f"Doom binds: {len(binds)} | Neovim leaders: {len(nvim)} | {counts}")
    print(f"Enabled modules: {len(enabled)}")


if __name__ == "__main__":
    main()
