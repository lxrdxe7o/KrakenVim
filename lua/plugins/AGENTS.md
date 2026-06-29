# Plugin Specifications

## Context
This directory contains all lazy.nvim plugin specifications organized by concern. Each file returns a Lua table (list of plugin spec tables) passed to `require("lazy").setup({ spec = { import = "plugins" } })`. Parent context: [../AGENTS.md](../AGENTS.md).

## File Map

| File | Plugins | Event Trigger |
|---|---|---|
| `editor.lua` | treesitter, neo-tree, indent-blankline, better-escape, neoscroll, which-key, gitsigns, comment.nvim, todo-comments, mini.{surround,ai,bracketed,move} | `BufReadPre`, `BufNewFile`, `VeryLazy` |
| `ui.lua` | lualine, bufferline, noice, dressing, snacks.nvim (dashboard/notifier/terminal), web-devicons | `VeryLazy`, eager (snacks) |
| `colorscheme.lua` | bamboo (default), miasma, cyberdream, gruvbox, catppuccin, tokyonight, onedark, kanagawa, rose-pine, nightfox, dracula, nord, everforest, solarized-osaka | lazy=false (bamboo), lazy=true (all others) |
| `completion.lua` | nvim-cmp, LuaSnip, copilot.lua, copilot-cmp, nvim-autopairs | `InsertEnter` |
| `lsp.lua` | mason, mason-lspconfig, lspconfig, schema-store, rustaceanvim, nvim-jdtls, conform (format), nvim-lint, lsp_signature | `BufReadPre`, `BufWritePre` (conform), `LspAttach` |
| `dap.lua` | nvim-dap, nvim-dap-ui, nvim-dap-virtual-text, mason-nvim-dap | `<leader>d*` keys |
| `tools.lua` | fzf-lua, telescope, yazi.nvim, compiler.nvim, overseer, live-server, markdown-preview, render-markdown, trouble, lazygit, toggleterm | `cmd`, `VeryLazy`, `<leader>f*`, `<leader>g*` |
| `extras.lua` | wakatime, presence.nvim, pomo.nvim, typr, obsidian.nvim | `VeryLazy`, `cmd`, `BufReadPre` for vaults |
| `ai.lua` | claudecode.nvim | `<leader>a*` keys |

## Patterns

### Plugin spec shape
```lua
{
  "author/plugin-name",          -- GitHub repo
  name = "alias",                -- optional, for non-standard names
  lazy = true,                   -- default; false for eager
  event = { "BufReadPre" },      -- lazy load trigger
  cmd = { "FzfLua" },           -- command-based load
  keys = { { "<leader>ff", ... } },  -- key-based load
  ft = { "rust" },               -- filetype-based load
  opts = { ... },                -- auto `require().setup(opts)` or manual `config = function()`
  config = function(_, opts) end, -- manual setup
  dependencies = { ... },        -- other plugin specs or strings
  build = ":TSUpdate",           -- post-install hook
}
```

### Key binding pattern
- Core (non-plugin) mappings go in `lua/config/keymaps.lua`.
- Plugin-specific mappings go in the spec's `keys` table or inside `config` with buffer-local `on_attach`.
- LSP keymaps defined in `lua/plugins/lsp.lua`'s `on_attach` function (shared by all LSP servers).
- `<leader>` group labels registered via which-key in `editor.lua`.

### Editor plugin choice rationale
- **fzf-lua** over telescope — native fzf performance, primary picker.
- **telescope** — kept as a dependency for compiler.nvim, no user-facing keymaps.
- **snacks.nvim** — provides dashboard, notifier, input, scroll, indent, terminal, bigfile, quickfile, and words all in one plugin. Replaces alpha.nvim (dashboard) and nvim-notify.
- **mini.*** over tree-sitter-textobjects — mini.ai provides textobjects compatible with treesitter 1.0.
- **rustaceanvim** over manual lspconfig — more complete Rust integration (runnables, testables, expand macro).
- **nvim-jdtls** over manual lspconfig for Java — necessary for DAP, test runner, and refactoring support; configured in `ftplugin/java.lua`.

## Constraints

- `lazy-lock.json` is gitignored — lazy.nvim auto-generates it.
- Never import `plugins` table in multiple places — `init.lua` does it once.
- When adding a new plugin, add it to the file that matches its concern (e.g., a new formatter → `lsp.lua`).
- Colorscheme plugins are all `lazy=true` except bamboo (the default). They must be loaded before they can be activated via `:colorscheme`.
- `nvim-jdtls` and `rust_analyzer` are skipped in `mason-lspconfig` handlers — they have dedicated configs.

## Key LSP Server Highlights

| Server | Config Location | Notes |
|---|---|---|
| lua_ls | `lsp.lua` | LuaJIT runtime, `vim` global, callSnippet=Replace |
| ts_ls | `lsp.lua` | Full inlay hints enabled for TS/JS |
| pyright | `lsp.lua` | basic type checking, auto search paths |
| gopls | `lsp.lua` | gofumpt, full hints, staticcheck |
| clangd | `lsp.lua` | background index, clang-tidy, IWYU |
| rust-analyzer | via rustaceanvim | full features, proc macros, inlay hints |
| jdtls | `ftplugin/java.lua` | dynamic runtime detection, DAP bundles, lombok |

## Debug Adapters
Defined in `dap.lua`: Python (debugpy), Go (delve), C/C++/Rust (codelldb), JS/TS (vscode-js-debug via pwa-node/pwa-chrome). Java DAP handled by nvim-jdtls.

## Ownership
- Generalists: `editor.lua`, `ui.lua`, `tools.lua`, `extras.lua`
- LSP specialist: `lsp.lua`
- Debugger specialist: `dap.lua`
- AI specialist: `ai.lua`
- Theme specialist: `colorscheme.lua`
- Completion specialist: `completion.lua`
