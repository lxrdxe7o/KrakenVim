# KRAKENVIM — Neovim Configuration

## Context
This is the root context for the entire KRAKENVIM Neovim configuration. It lives at `~/.config/nvim/` and manages every aspect of the editor: options, keymaps, plugins, LSP, debugging, UI, themes, and dashboard imagery.

## Architecture Overview
- **Entry point**: `init.lua` bootstraps lazy.nvim, loads core config modules, then imports plugin specs.
- **Core config** (`lua/config/`): options, keymaps, autocommands, colorscheme persistence.
- **Plugin specs** (`lua/plugins/`): one file per concern — editor, UI, LSP, DAP, completion, tools, extras, AI, colorschemes.
- **Utilities** (`lua/utils/`): image manager for dashboard header cycling.
- **ASCII headers** (`ascii/headers/`): Lua-format ASCII art displayed on the dashboard.
- **Filetype plugins** (`ftplugin/`): Java-only LSP configuration via nvim-jdtls.
- **Dashboard imagery** (`img/`): JPG images rendered by chafa for the Snacks dashboard.

## Key Paths

| Path | Purpose |
|---|---|
| `init.lua` | Entry point — bootstrap lazy.nvim, load config, theme |
| `lua/config/options.lua` | Editor options (tabs, search, appearance, performance) |
| `lua/config/keymaps.lua` | Core key mappings (leader groups, navigation, LSP) |
| `lua/config/autocmds.lua` | Autocommands (trim whitespace, yank highlight, splits) |
| `lua/config/colorscheme.lua` | Persistent theme picker + fzf integration |
| `lua/plugins/editor.lua` | Core editor plugins (treesitter, neo-tree, gitsigns, mini.*) |
| `lua/plugins/ui.lua` | UI plugins (lualine, bufferline, noice, snacks dashboard) |
| `lua/plugins/lsp.lua` | LSP config (mason, lspconfig, conform, lint, rustaceanvim) |
| `lua/plugins/dap.lua` | Debugging (nvim-dap, adapters for Python/Go/C++/Rust/JS) |
| `lua/plugins/completion.lua` | Autocompletion (nvim-cmp, luasnip, copilot) |
| `lua/plugins/colorscheme.lua` | 15 theme plugins (bamboo default, lazy-loaded) |
| `lua/plugins/tools.lua` | Tools (fzf-lua, yazi, compiler.nvim, toggleterm, trouble) |
| `lua/plugins/extras.lua` | Extras (wakatime, discord presence, pomodoro, obsidian) |
| `lua/plugins/ai.lua` | AI integration (claudecode.nvim) |
| `lua/utils/img_manager.lua` | Image cycling/persistence for snacks dashboard |
| `lua/krakenvim/health.lua` | `:checkhealth krakenvim` module |
| `ftplugin/java.lua` | Java LSP config (jdtls, dynamic runtime detection) |
| `scripts/img2ascii.sh` | Convert images to ASCII art Lua headers |

## Patterns
- **Modular plugin specs**: each `lua/plugins/` file returns a table of plugin specs for lazy.nvim.
- **AstroNvim-style keybindings**: `<leader>` groups follow AstroNvim conventions (f=find, g=git, l=LSP, etc.).
- **Lazy loading aggressive**: plugins specify `event`, `cmd`, `keys`, `ft` triggers to defer loading.
- **Persistent theme**: colorscheme selection is persisted to disk and restored across sessions via `lua/config/colorscheme.lua`.
- **Two dashboard header modes**: image (chafa from `img/`) or ASCII art (from `ascii/headers/`), switchable via `header_mode` in `ui.lua`.
- **LSP handlers pattern**: shared `on_attach` and `capabilities` passed to all `lspconfig` setups via `make_config()` helper.
- **Mason auto-install**: LSP servers, formatters, linters, and DAP adapters auto-installed on first file open.

## Constraints
- Neovim >= 0.10 required (for inlay hints, treesitter 1.0 API).
- External tools required: `git`, `rg` (ripgrep), `chafa` (for image headers), `lazygit` (for git UI).
- `tree-sitter-textobjects` is disabled — `mini.ai` replaces it due to TS 1.0 incompatibility.
- `nvim-notify` is disabled — Snacks notifier is the primary notification backend.
- Java LSP (jdtls) and Rust LSP (rust-analyzer) are handled outside mason-lspconfig handlers, in `ftplugin/java.lua` and `rustaceanvim` respectively.

## Ownership
- **Root**: generalist — any profile can work here
- **lua/plugins/lsp.lua**: LSP specialist
- **lua/plugins/dap.lua**: debugger specialist
- **lua/plugins/**: plugin specialist — understands lazy.nvim spec format
- **ftplugin/java.lua**: Java specialist
- **ascii/**: art/design profile

## Discovery Heuristics
- Missing LSP server → check `lua/plugins/lsp.lua` for ensure_installed list and `mason-lspconfig` handlers
- Missing keymap → check `lua/config/keymaps.lua` (core), then respective plugin file (plugin-specific)
- Theme not working → check `lua/plugins/colorscheme.lua` (plugin config) and `lua/config/colorscheme.lua` (loader/picker)
- Debugger not launching → check `lua/plugins/dap.lua` for adapter configuration
- New plugin → add spec to the appropriate `lua/plugins/*.lua` file, following existing patterns

## Links
- [Lua modules](lua/AGENTS.md)
- [Plugin specifications](lua/plugins/AGENTS.md)
- [ASCII headers](ascii/AGENTS.md)
- [Filetype plugins](ftplugin/AGENTS.md)
- [Scripts](scripts/AGENTS.md)
