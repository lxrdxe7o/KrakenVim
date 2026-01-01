-- UI plugins (dashboard, statusline, bufferline, notifications, etc.)
-- Note: Colorscheme plugins are in lua/plugins/colorscheme.lua

return {
	-- Alpha: Dashboard
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")
		local HeaderManager = require("utils.header_manager")

		-- Initialize header manager
		HeaderManager.init()

		-- Apply current header to dashboard
		HeaderManager.apply_to_dashboard(dashboard)

		-- Customize buttons
		dashboard.section.buttons.val = {
			dashboard.button("f", "🔍  Find file", "<cmd>Telescope find_files<cr>"),
			dashboard.button("n", "📄  New file", "<cmd>ene <BAR> startinsert<cr>"),
			dashboard.button("r", "🕒  Recent files", "<cmd>Telescope oldfiles<cr>"),
			dashboard.button("g", "🔎  Find text", "<cmd>Telescope live_grep<cr>"),
			dashboard.button("c", "⚙️  Config", "<cmd>e $MYVIMRC<cr>"),
			dashboard.button("i", "🎨  Next header", "<cmd>AlphaHeaderNext<cr>"),
			dashboard.button("l", "💤  Lazy", "<cmd>Lazy<cr>"),
			dashboard.button("q", "❌  Quit", "<cmd>qa<cr>"),
		}

		-- Dynamic footer with plugin stats
		dashboard.section.footer.opts.hl = "AlphaFooter"
		dashboard.section.footer.val = "⚡ Welcome to Neovim"

		alpha.setup(dashboard.config)

		-- Helper function to refresh the dashboard
		local function refresh_dashboard()
			-- Update the existing dashboard object instead of creating a new one
			HeaderManager.apply_to_dashboard(dashboard)
			
			-- Re-setup alpha with updated config
			alpha.setup(dashboard.config)
			
			-- Close any existing alpha buffers to force a clean state
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "alpha" then
					-- Close all windows showing this buffer first
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
							pcall(vim.api.nvim_win_close, win, true)
						end
					end
					-- Then delete the buffer
					pcall(vim.api.nvim_buf_delete, buf, { force = true })
				end
			end
			
			-- Use vim.schedule to ensure the buffer/window deletion completes
			vim.schedule(function()
				-- Now open alpha with the Alpha command
				vim.cmd("Alpha")
			end)
		end

		-- Create user commands for header cycling
		vim.api.nvim_create_user_command("AlphaHeaderNext", function()
			HeaderManager.next()
			HeaderManager.save_state()
			refresh_dashboard()
		end, { desc = "Cycle to next header" })

		vim.api.nvim_create_user_command("AlphaHeaderPrev", function()
			HeaderManager.prev()
			HeaderManager.save_state()
			refresh_dashboard()
		end, { desc = "Cycle to previous header" })

		vim.api.nvim_create_user_command("AlphaHeaderRandom", function()
			HeaderManager.random()
			HeaderManager.save_state()
			refresh_dashboard()
		end, { desc = "Jump to random header" })

		vim.api.nvim_create_user_command("AlphaHeaderName", function()
			local name = HeaderManager.get_current_name()
			local count = HeaderManager.get_count()
			vim.notify(
				string.format("Current header: %s (%d/%d)", name, HeaderManager.current_index, count),
				vim.log.levels.INFO
			)
		end, { desc = "Show current header name" })

		-- Autocmd to update footer after startup stats are available
		vim.api.nvim_create_autocmd("User", {
			once = true,
			pattern = "LazyVimStarted",
			callback = function()
				local stats = require("lazy").stats()
				local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
				dashboard.section.footer.val = "⚡ Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"
				
				-- Only redraw if there's a valid alpha buffer visible
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					if vim.api.nvim_win_is_valid(win) then
						local buf = vim.api.nvim_win_get_buf(win)
						if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "alpha" then
							pcall(vim.cmd.AlphaRedraw)
							break
						end
					end
				end
			end,
		})

		-- Create a command to toggle Alpha dashboard
		vim.api.nvim_create_user_command("AlphaDashboard", function()
			-- Check if current buffer is alpha
			local current_buf = vim.api.nvim_get_current_buf()
			if vim.bo[current_buf].filetype == "alpha" then
				-- If on alpha, go to alternate buffer or create new one
				local alt_buf = vim.fn.bufnr("#")
				if alt_buf ~= -1 and vim.api.nvim_buf_is_valid(alt_buf) and vim.bo[alt_buf].buflisted then
					vim.cmd("buffer " .. alt_buf)
				else
					-- Find any listed buffer that's not alpha
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.api.nvim_buf_is_valid(buf) 
							and vim.bo[buf].buflisted 
							and vim.bo[buf].filetype ~= "alpha" then
							vim.cmd("buffer " .. buf)
							return
						end
					end
					-- No other buffer found, create a new one
					vim.cmd("enew")
				end
			else
				-- Not on alpha, open it
				refresh_dashboard()
			end
		end, { desc = "Toggle Alpha Dashboard" })
	end,
		keys = {
			{ "<leader>h", "<cmd>AlphaDashboard<cr>", desc = "Home (Alpha Dashboard)" },
		},
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
