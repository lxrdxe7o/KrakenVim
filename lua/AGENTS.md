# Lua Source Modules

## Context
This directory contains all Lua source modules for the KRAKENVIM Neovim configuration. Each subdirectory and file serves a specific architectural concern. Parent context: [../AGENTS.md](../AGENTS.md).

## Structure

```
lua/
├── config/          # Core configuration (options, keymaps, autocmds, colorscheme)
│   ├── options.lua      → Editor options (tabs, search, display, performance)
│   ├── keymaps.lua      → Core key mappings with AstroNvim-style <leader> groups
│   ├── autocmds.lua     → Autocommands (yank highlight, trim whitespace, splits)
│   └── colorscheme.lua  → Persistent colorscheme picker with fzf-lua
├── plugins/         # Plugin specifications for lazy.nvim (see plugins/AGENTS.md)
├── utils/
│   └── img_manager.lua  → Dashboard image cycling, persistence, scanning
├── ascii/
│   └── loader.lua       → ASCII header loading, cycling, and display commands
└── krakenvim/
    └── health.lua       → :checkhealth krakenvim — validates installation
```

## Key Paths

| Path | Purpose |
|---|---|
| `lua/config/options.lua` | `vim.opt` settings — relative numbers, 2-space tabs, truecolor, clipboard, diagnostics |
| `lua/config/keymaps.lua` | All core mappings — window nav, buffer mgmt, find (fzf), git, LSP, terminal, toggles |
| `lua/config/autocmds.lua` | 5 autocommand groups: YankHighlight, TrimWhitespace, LastPosition, TerminalSettings, ResizeSplits |
| `lua/config/colorscheme.lua` | `get_saved_colorscheme()` / `save_colorscheme()` / `pick_colorscheme()` with fzf |
| `lua/utils/img_manager.lua` | `init()`, `next()`, `prev()`, `random()`, `save_state()`, `load_state()` for `img/` cycling |
| `lua/ascii/loader.lua` | `get_ascii_cmd()`, `setup()`, header cycling from `ascii/headers/` files |
| `lua/krakenvim/health.lua` | Health checks: Neovim version, external tools, LSP servers, mason, treesitter parsers, config loading |

## Patterns

- **config modules are thin**: they set options, map keys, or register events — no business logic.
- **colorscheme module is self-contained**: disk-persistence, fzf integration, preview, and safe fallback all in one file.
- **health module mirrors init.lua load order**: config files (options→keymaps→autocmds→colorscheme), then plugins, then treesitter.
- **img_manager and ascii/loader share the same API shape**: `init()`, `next()`, `prev()`, `random()`, `get_current()`, and a persistent state file.
- **All require() calls use relative lua paths** (dots for slashes, e.g., `require("config.options")`).

## Constraints

- `config/compat` is referenced in the health check (`lua/krakenvim/health.lua`) but no `lua/config/compat.lua` file exists — the pcall handles it gracefully.
- The `lua/utils/` directory only has `img_manager.lua`; new utilities go here.
- `lua/ascii/loader.lua` loads `.lua` files from `ascii/headers/` that return `{ header = {"line1", "line2", ...} }`.
- LuaJIT runtime expected (Neovim built with LuaJIT).

## Ownership
- `lua/config/` — generalist (core setup)
- `lua/utils/` — generalist or utility specialist
- `lua/krakenvim/health.lua` — DevOps / QA profile
- `lua/ascii/loader.lua` — creative / art profile
