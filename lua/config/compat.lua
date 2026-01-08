-- Compatibility shims for nvim-treesitter 1.0+ and Neovim 0.11+
-- This file patches older plugins to work with the new treesitter API

local M = {}

-- Apply shim to vim.treesitter.language
local function shim_vim_treesitter()
	if vim.treesitter and vim.treesitter.language and not vim.treesitter.language.ft_to_lang then
		vim.treesitter.language.ft_to_lang = vim.treesitter.language.get_lang
	end
end

-- Apply shim to nvim-treesitter.parsers
local function shim_nvim_treesitter_parsers()
	local ok, parsers = pcall(require, "nvim-treesitter.parsers")
	if ok and parsers then
		if not parsers.ft_to_lang then
			parsers.ft_to_lang = function(ft)
				if vim.treesitter and vim.treesitter.language and vim.treesitter.language.get_lang then
					return vim.treesitter.language.get_lang(ft) or ft
				end
				return ft
			end
		end
		if not parsers.get_parser then
			parsers.get_parser = function(bufnr, lang)
				return vim.treesitter.get_parser(bufnr, lang)
			end
		end
	end
end

-- Apply shim to nvim-treesitter.configs
local function shim_nvim_treesitter_configs()
	local ok, configs = pcall(require, "nvim-treesitter.configs")
	if ok and configs then
		if not configs.is_enabled then
			configs.is_enabled = function(mod, lang, bufnr)
				-- Return true to allow treesitter highlighting
				return true
			end
		end
		if not configs.get_module then
			configs.get_module = function(mod)
				return { additional_vim_regex_highlighting = false }
			end
		end
	end
end

function M.setup()
	shim_vim_treesitter()
	shim_nvim_treesitter_parsers()
	shim_nvim_treesitter_configs()
	
	-- Also apply shims after VeryLazy to catch any lazy-loaded modules
	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		once = true,
		callback = function()
			shim_nvim_treesitter_parsers()
			shim_nvim_treesitter_configs()
		end,
	})
end

return M
