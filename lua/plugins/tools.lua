return {
	-- FZF-Lua: Fast fuzzy finder (primary picker)
	{
		"ibhagwan/fzf-lua",
		cmd = "FzfLua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			-- File pickers
			{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files" },
			{ "<leader>fF", "<cmd>FzfLua files no_ignore=true hidden=true<cr>", desc = "Find All Files" },
			{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
			{ "<leader>fo", "<cmd>FzfLua oldfiles<cr>", desc = "Recent Files" },
			{ "<leader>fr", "<cmd>FzfLua registers<cr>", desc = "Registers" },
			-- Search
			{ "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
			{ "<leader>fw", "<cmd>FzfLua grep_cword<cr>", desc = "Grep Word Under Cursor" },
			{ "<leader>fW", "<cmd>FzfLua grep_cWORD<cr>", desc = "Grep WORD Under Cursor" },
			{ "<leader>f/", "<cmd>FzfLua lgrep_curbuf<cr>", desc = "Search in Buffer" },
			{ "<leader>/", "<cmd>FzfLua lgrep_curbuf<cr>", desc = "Search in Buffer" },
			-- LSP
			{ "<leader>fd", "<cmd>FzfLua diagnostics_document<cr>", desc = "Document Diagnostics" },
			{ "<leader>fD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "Workspace Diagnostics" },
			{ "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", desc = "Document Symbols" },
			-- Help & Misc
			{ "<leader>fh", "<cmd>FzfLua help_tags<cr>", desc = "Help Tags" },
			{ "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
			{ "<leader>fm", "<cmd>FzfLua marks<cr>", desc = "Marks" },
			{ "<leader>fC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
			-- Git
			{ "<leader>gb", "<cmd>FzfLua git_branches<cr>", desc = "Git Branches" },
			{ "<leader>gc", "<cmd>FzfLua git_commits<cr>", desc = "Git Commits" },
			{ "<leader>gC", "<cmd>FzfLua git_bcommits<cr>", desc = "Git Buffer Commits" },
			{ "<leader>gs", "<cmd>FzfLua git_status<cr>", desc = "Git Status" },
			{ "<leader>gS", "<cmd>FzfLua git_stash<cr>", desc = "Git Stash" },
			-- Quick access
			{ "<leader><leader>", "<cmd>FzfLua buffers<cr>", desc = "Switch Buffer" },
			{ "<leader>sr", "<cmd>FzfLua resume<cr>", desc = "Resume Last Search" },
		},
		opts = {
			-- Global fzf options
			fzf_opts = {
				["--layout"] = "reverse",
				["--info"] = "inline",
			},
			-- Window options
			winopts = {
				height = 0.85,
				width = 0.80,
				row = 0.35,
				col = 0.50,
				border = "rounded",
				preview = {
					layout = "flex",
					flip_columns = 120,
					scrollbar = "float",
				},
			},
			-- Keymaps inside fzf window
			keymap = {
				builtin = {
					["<C-d>"] = "preview-page-down",
					["<C-u>"] = "preview-page-up",
					["<C-j>"] = "down",
					["<C-k>"] = "up",
				},
				fzf = {
					["ctrl-q"] = "select-all+accept",
					["ctrl-d"] = "preview-page-down",
					["ctrl-u"] = "preview-page-up",
				},
			},
			-- File picker options
			files = {
				hidden = true,
				follow = true,
				fd_opts = "--type f --hidden --follow --exclude .git --exclude node_modules",
			},
			-- Grep options
			grep = {
				hidden = true,
				rg_opts = "--column --line-number --no-heading --color=always --smart-case --hidden -g '!.git' -g '!node_modules'",
			},
			-- Oldfiles
			oldfiles = {
				cwd_only = false,
				include_current_session = true,
			},
		},
	},

	-- Telescope (minimal - only for plugin dependencies like compiler.nvim)
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		lazy = true, -- Only load when explicitly needed by other plugins
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = { "node_modules", ".git/" },
				},
			})
		end,
		-- No keys - fzf-lua handles all picker keymaps
	},

	-- Yazi: File manager
	{
		"mikavilpas/yazi.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>-", "<cmd>Yazi<cr>", mode = { "n", "v" }, desc = "Open Yazi at current file" },
			{ "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Open Yazi in cwd" },
			{ "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Resume last Yazi session" },
		},
		opts = {
			open_for_directories = false,
			keymaps = { show_help = "<f1>" },
		},
		init = function()
			vim.g.loaded_netrwPlugin = 1
		end,
	},

	-- Compiler.nvim
	{
		"Zeioth/compiler.nvim",
		cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
		dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
		opts = {},
		keys = {
			{ "<F6>", "<cmd>CompilerOpen<cr>", desc = "Open Compiler" },
			{ "<S-F6>", "<cmd>CompilerToggleResults<cr>", desc = "Toggle Compiler Results" },
			-- Note: F7 is reserved for ToggleTerm, use <S-F6> to toggle compiler results
		},
	},

	-- Overseer: Task runner
	{
		"stevearc/overseer.nvim",
		cmd = { "OverseerRun", "OverseerToggle", "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
		opts = {
			task_list = {
				direction = "bottom",
				min_height = 25,
				max_height = 25,
				default_detail = 1,
			},
		},
	},

	-- Live Server
	-- Use :LiveServerStart and :LiveServerStop commands
	{
		"barrett-ruth/live-server.nvim",
		cmd = { "LiveServerStart", "LiveServerStop" },
		opts = {},
	},

	-- Markdown Preview
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		ft = { "markdown" },
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle Markdown Preview" },
		},
	},

	-- Render Markdown
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {},
	},

	-- Diagnostics list
	{
		"folke/trouble.nvim",
		cmd = { "Trouble", "TroubleToggle" },
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
			{ "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
			{ "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
		},
	},

	-- Lazygit
	{
		"kdheepak/lazygit.nvim",
		cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},

	-- Toggleterm
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = { "ToggleTerm", "TermExec" },
		keys = {
			{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float terminal" },
			{ "<leader>th", "<cmd>ToggleTerm direction=horizontal size=10<cr>", desc = "Horizontal terminal" },
			{ "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Vertical terminal" },
			{ "<F7>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
		},
		opts = {
			size = function(term)
				if term.direction == "horizontal" then
					return 15
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.4
				end
			end,
			open_mapping = [[<F7>]],
			hide_numbers = true,
			shade_terminals = true,
			shading_factor = 2,
			start_in_insert = true,
			insert_mappings = true,
			terminal_mappings = true,
			persist_size = true,
			direction = "float",
			close_on_exit = true,
			shell = vim.o.shell,
			float_opts = {
				border = "curved",
				winblend = 0,
			},
		},
	},
}
