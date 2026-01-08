-- KRAKENVIM - A modern, modular Neovim configuration

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Load core configuration
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{ import = "plugins" },
	},
	install = { colorscheme = { "bamboo", "habamax" } },
	ui = {
		backdrop = 100,
		border = "rounded",
	},
	checker = {
		enabled = true,
		notify = false,
	},
	change_detection = {
		enabled = true,
		notify = false,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"zipPlugin",
				"tutor",
				"rplugin",
			},
		},
	},
})

-- Apply nvim-treesitter 1.0 compatibility shims for older plugins (e.g., Telescope)
require("config.compat").setup()

-- Load persisted colorscheme IMMEDIATELY after lazy.setup()
do
	local cs = require("config.colorscheme")
	local saved = cs.get_saved_colorscheme()
	cs.apply_colorscheme(saved)
end

-- Show startup message after everything is ready
vim.api.nvim_create_autocmd("User", {
	pattern = "LazyDone",
	once = true,
	callback = function()
		vim.defer_fn(function()
			local cs = require("config.colorscheme")
			local saved = cs.get_saved_colorscheme()
			local current = vim.g.colors_name or "none"
			if current ~= saved then
				vim.notify("KRAKENVIM | Theme: " .. current .. " (expected: " .. saved .. ")", vim.log.levels.WARN)
			else
				vim.notify("KRAKENVIM | Theme: " .. current, vim.log.levels.INFO)
			end
		end, 100)
	end,
})
