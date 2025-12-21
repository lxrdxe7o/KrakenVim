-- UI plugins (dashboard, statusline, bufferline, notifications, etc.)
-- Note: Colorscheme plugins are in lua/plugins/colorscheme.lua

return {
	-- Alpha: Dashboard
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<leader>h", "<cmd>Alpha<cr>", desc = "Home (Alpha Dashboard)" },
		},
		config = function()
			local alpha = require("alpha")
			local dashboard = require("alpha.themes.dashboard")

			-- Custom header
			dashboard.section.header.val = {
				"                                   ",
				"                                   ",
				"                                   ",
				"   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ",
				"    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ",
				"          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄     ",
				"           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ",
				"          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ",
				"   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ",
				"  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ",
				" ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ",
				" ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ",
				"      ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆     ",
				"       ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃     ",
				"                                   ",
				" ⠀ ⠀⠀   ⠀K⠀R⠀A⠀K E N V I M⠀⠀⠀⠀⠀⠀⠀⠀⠀",
			}

			dashboard.section.buttons.val = {
				dashboard.button("f", "  Find file", "<cmd>Telescope find_files<cr>"),
				dashboard.button("n", "  New file", "<cmd>ene <BAR> startinsert<cr>"),
				dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<cr>"),
				dashboard.button("g", "  Find text", "<cmd>Telescope live_grep<cr>"),
				dashboard.button("c", "  Config", "<cmd>e $MYVIMRC<cr>"),
				dashboard.button("l", "󰒲  Lazy", "<cmd>Lazy<cr>"),
				dashboard.button("q", "  Quit", "<cmd>qa<cr>"),
			}

			-- Dynamic footer with plugin stats
			dashboard.section.footer.opts.hl = "AlphaFooter"
			dashboard.section.footer.val = function()
				local stats = require("lazy").stats()
				local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
				return {
					"If You Don't Take Risks, You Can't Create a Future.",
					" ",
					"                                  - Monkey D. Luffy",
					" ",
					"       Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
				}
			end

			alpha.setup(dashboard.config)
		end,
	},

	-- Lualine: Statusline
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = "auto",
				globalstatus = true,
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { { "filename", path = 1 } },
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		},
	},

	-- Bufferline
	{
		"akinsho/bufferline.nvim",
		version = "*",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				mode = "buffers",
				diagnostics = "nvim_lsp",
				always_show_bufferline = false,
				offsets = {
					{
						filetype = "neo-tree",
						text = "File Explorer",
						highlight = "Directory",
						separator = true,
					},
				},
			},
		},
		keys = {
			{ "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin Buffer" },
			{ "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Close Non-Pinned" },
			{ "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close Others" },
			{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		},
	},

	-- Noice: UI for messages, cmdline, popupmenu
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		opts = {
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = false,
				lsp_doc_border = true,
			},
		},
	},

	-- Nvim-notify
	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 3000,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.75)
			end,
		},
	},

	-- Dressing: Better UI inputs
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = {},
	},

	-- Web devicons
	{ "nvim-tree/nvim-web-devicons", lazy = true },
}
