-- Health check module for KRAKENVIM
-- Run with :checkhealth krakenvim

local M = {}

local health = vim.health

function M.check()
  health.start("KRAKENVIM")

  -- Check Neovim version
  local nvim_version = vim.version()
  local version_str = string.format("%d.%d.%d", nvim_version.major, nvim_version.minor, nvim_version.patch)
  if nvim_version.minor >= 10 then
    health.ok("Neovim version: " .. version_str)
  else
    health.warn("Neovim version " .. version_str .. " (0.10+ recommended for best experience)")
  end

  -- Check required external tools
  health.start("Required Tools")
  local required_tools = {
    { cmd = "git", name = "Git", required = true },
    { cmd = "rg", name = "ripgrep (rg)", required = true },
    { cmd = "fd", name = "fd-find", required = false },
    { cmd = "node", name = "Node.js", required = false },
    { cmd = "npm", name = "npm", required = false },
  }

  for _, tool in ipairs(required_tools) do
    if vim.fn.executable(tool.cmd) == 1 then
      local version = vim.fn.system(tool.cmd .. " --version 2>/dev/null"):gsub("\n.*", "")
      health.ok(tool.name .. ": " .. version)
    elseif tool.required then
      health.error(tool.name .. " not found (required)")
    else
      health.warn(tool.name .. " not found (optional)")
    end
  end

  -- Check language-specific tools
  health.start("Language Tools")
  local lang_tools = {
    { cmd = "lua-language-server", name = "Lua LSP" },
    { cmd = "pyright", name = "Python LSP (pyright)" },
    { cmd = "gopls", name = "Go LSP" },
    { cmd = "rust-analyzer", name = "Rust LSP" },
    { cmd = "clangd", name = "C/C++ LSP" },
    { cmd = "stylua", name = "Lua formatter (stylua)" },
    { cmd = "black", name = "Python formatter (black)" },
    { cmd = "prettierd", name = "JS/TS formatter (prettierd)" },
  }

  for _, tool in ipairs(lang_tools) do
    if vim.fn.executable(tool.cmd) == 1 then
      health.ok(tool.name .. " found")
    else
      health.info(tool.name .. " not found (install via Mason if needed)")
    end
  end

  -- Check plugin manager
  health.start("Plugin Manager")
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    local stats = lazy.stats()
    health.ok(string.format("lazy.nvim loaded (%d/%d plugins)", stats.loaded, stats.count))
  else
    health.error("lazy.nvim not loaded")
  end

  -- Check key plugins
  health.start("Core Plugins")
  local core_plugins = {
    { name = "nvim-treesitter", module = "nvim-treesitter" },
    { name = "telescope.nvim", module = "telescope" },
    { name = "nvim-lspconfig", module = "lspconfig" },
    { name = "nvim-cmp", module = "cmp" },
    { name = "mason.nvim", module = "mason" },
  }

  for _, plugin in ipairs(core_plugins) do
    local ok = pcall(require, plugin.module)
    if ok then
      health.ok(plugin.name .. " loaded")
    else
      health.warn(plugin.name .. " not loaded (may be lazy-loaded)")
    end
  end

  -- Check treesitter parsers
  health.start("Treesitter Parsers")
  local ts_ok, _ = pcall(require, "nvim-treesitter")
  if ts_ok then
    local essential_parsers = { "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" }
    for _, parser in ipairs(essential_parsers) do
      local has_parser = pcall(vim.treesitter.language.inspect, parser)
      if has_parser then
        health.ok(parser .. " parser installed")
      else
        health.warn(parser .. " parser not installed (run :TSInstall " .. parser .. ")")
      end
    end
  else
    health.info("Treesitter not loaded yet (lazy-loaded)")
  end

  -- Check configuration files
  health.start("Configuration")
  local config_files = {
    "config.options",
    "config.keymaps",
    "config.autocmds",
    "config.colorscheme",
    "config.compat",
  }

  for _, module in ipairs(config_files) do
    local ok, err = pcall(require, module)
    if ok then
      health.ok(module .. " loaded")
    else
      health.error(module .. " failed to load: " .. tostring(err))
    end
  end

  -- Check colorscheme
  health.start("Colorscheme")
  local cs = require("config.colorscheme")
  local saved = cs.get_saved_colorscheme()
  local current = vim.g.colors_name or "none"
  if current == saved then
    health.ok("Colorscheme: " .. current)
  else
    health.warn("Colorscheme mismatch: current=" .. current .. ", saved=" .. saved)
  end
end

return M
