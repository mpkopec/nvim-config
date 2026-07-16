# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Setup and Installation

```bash
bash install.sh   # installs curl if needed, downloads vim-plug, launches nvim
```

After first launch, run `:PlugInstall` inside Neovim to install all plugins.

Plugins with build steps (run automatically by vim-plug):
- **YouCompleteMe**: `python3 install.py` — compiles the C++ completion engine
- **telescope-fzf-native**: `make` — builds the C fzf extension

External dependencies: `python3`, `curl`, `ctags` (optional, for gutentags), `black` (Python formatter), `okular` (LaTeX PDF viewer), `wsl-clip` (WSL clipboard bridge).

The VHDL `inst:entity_name` instantiation snippet (`UltiSnips/vhdl.snippets`) additionally needs `hdl-signature` importable from Neovim's own `python3` provider — not necessarily the system `python3` on `$PATH`, since that provider can be a separate interpreter (e.g. a pipx-managed venv for `pynvim`). Check which interpreter that is with `:checkhealth provider`, then install into it, e.g.:
```bash
pipx inject pynvim "hdl-signature @ git+https://github.com/mpkopec/hdl-signature.git"
```

## Architecture

**Entry point**: `init.vim` sources all other files in order.

**Configuration files** (vimscript, root level):
- `plugins.vim` — vim-plug declarations with conditional loading
- `basic-settings.vim` — core settings, folding logic (`CloseFoldsInnerFirst()`), color/indent
- `basic-maps.vim` — window navigation, fold/line movement keymaps
- `leader-maps.vim` — comma-leader mappings (`,w` save, `,e` exit, `,l` next buffer, etc.)
- `basic-acmds.vim` — autocommands (trailing whitespace trim, filetype overrides)
- `ftype-settings.vim` — language-specific config (Python/Black, VHDL, Verilog, Markdown)
- `wsl-clip.vim` — WSL clipboard bridge (syncs `+` register with Windows clipboard)
- `vscode-settings.vim` — conditionally loaded when running inside VS Code extension

**Per-plugin configs**: `plugconf/` — one file per plugin, self-contained, sourced from `init.vim`.

**Filetype overrides**: `after/` directory.

## Key Patterns

**Conditional loading** gates plugin/feature activation:
```vim
if has('nvim')      " Neovim-only plugins (Telescope, Lua plugins)
if has('python3')   " YCM, UltiSnips
if exists('g:vscode') " VS Code-specific bindings (uses VSCodeNotify)
```

**Leader key**: `,` (comma). Mappings follow mnemonic conventions: `,pf` = Python format, `,mf` = motion find, `,ve`/`,vv`/`,vl` = edit config files.

**Lua usage**: Only for Neovim-specific plugins (Telescope in `plugconf/telescope.vim`, `plugconf/md-section-number.lua`). Everything else is vimscript.

**Folding**: Custom `CloseFoldsInnerFirst()` function for hierarchical closure; Verilog uses structural keyword-based fold expressions (defined in `plugconf/verilog_systemverilog.vim`).
