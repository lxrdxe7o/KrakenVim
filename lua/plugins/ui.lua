-- UI plugins (dashboard, statusline, bufferline, notifications, etc.)
-- Note: Colorscheme plugins are in lua/plugins/colorscheme.lua

return {
	-- NOTE: Dashboard moved to snacks.nvim in lua/plugins/ai.lua
	-- Alpha.nvim is disabled in favor of snacks.nvim dashboard

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
	-- Now uses snacks.nvim notifier instead of nvim-notify
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"folke/snacks.nvim", -- Using snacks notifier
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
			-- Route notifications to snacks.nvim notifier
			routes = {
				{
					filter = { event = "notify" },
					view = "notify",
				},
			},
		},
	},

	-- NOTE: nvim-notify disabled in favor of snacks.nvim notifier (lua/plugins/ai.lua)

	-- Dressing: Better UI selections (uses fzf-lua)
	-- NOTE: Input is handled by snacks.nvim
	{
		"stevearc/dressing.nvim",
		event = "VeryLazy",
		opts = {
			select = {
				enabled = true,
				backend = { "fzf_lua", "builtin" },
				fzf_lua = {
					winopts = {
						height = 0.5,
						width = 0.5,
					},
				},
			},
			input = {
				enabled = false, -- Using snacks.nvim input
			},
		},
	},

	-- Snacks.nvim: Dashboard, notifications, terminal, and more
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		config = function()
			local ImgManager = require("utils.img_manager")

			-- Initialize image manager
			ImgManager.init()

			local Snacks = require("snacks")

			-- Build the chafa command for current image
			local function get_image_cmd()
				local img_path = ImgManager.get_current()
				if not img_path then
					return "echo 'No images found in img/ folder'"
				end
				-- Use chafa to render image as colored unicode
				-- --size restricts output dimensions (cols x rows)
				-- --format symbols uses unicode block/braille characters
				return string.format("chafa --size=48x20 --animate=off %q", img_path)
			end

			-- Menu items with modern icons and styling
			local menu_items = {
				{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
				{ icon = " ", key = "f", desc = "Find File", action = ":FzfLua files" },
				{ icon = " ", key = "g", desc = "Find Text", action = ":FzfLua live_grep" },
				{ icon = " ", key = "r", desc = "Recent Files", action = ":FzfLua oldfiles" },
				{ icon = " ", key = "c", desc = "Config", action = ":e $MYVIMRC" },
				{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
				{ icon = " ", key = "i", desc = "Cycle Image", action = ":SnacksDashboardImageNext" },
				{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
			}

			-- Custom key format with icon
			local function format_key(item)
				return {
					{ "[", hl = "SnacksDashboardSpecial" },
					{ item.key, hl = "SnacksDashboardKey" },
					{ "]", hl = "SnacksDashboardSpecial" },
				}
			end

			local function format_icon(item)
				return { { item.icon, hl = "SnacksDashboardIcon" } }
			end

			Snacks.setup({
				-- Terminal support for claudecode
				terminal = { enabled = true },
				-- Handle large files
				bigfile = { enabled = true },
				-- Quick file loading
				quickfile = { enabled = true },
				-- Word highlighting
				words = { enabled = true },
				-- Status column disabled
				statuscolumn = { enabled = false },
				-- Smooth scrolling
				scroll = {
					enabled = true,
					animate = {
						duration = { step = 15, total = 150 },
						easing = "linear",
					},
				},
				-- Indent guides
				indent = {
					enabled = false,
					indent = {
						char = "│",
						blank = " ",
					},
					scope = {
						enabled = true,
						char = "│",
						underline = false,
						only_current = false,
					},
				},
				-- Input UI improvements
				input = { enabled = true },
				-- Git integration (lazygit)
				lazygit = { enabled = true },

				-- Snacks notifier as main notification system
				notifier = {
					enabled = true,
					timeout = 3000,
					width = { min = 40, max = 0.4 },
					height = { min = 1, max = 0.6 },
					margin = { top = 0, right = 1, bottom = 0 },
					padding = true,
					sort = { "level", "added" },
					level = vim.log.levels.TRACE,
					icons = {
						error = " ",
						warn = " ",
						info = " ",
						debug = " ",
						trace = " ",
					},
					style = "fancy",
					top_down = true,
					date_format = "%R",
					more_format = " ↓ %d more notifications",
					refresh = 50,
				},

				-- Dashboard configuration
				dashboard = {
					enabled = true,
					row = nil,
					col = nil,
					pane_gap = 6,
					autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
					preset = {
						keys = menu_items,
						-- Header is handled by custom section below
					},
					formats = {
						key = format_key,
						icon = format_icon,
					},
					sections = {
						{ section = "startup", padding = 1 },
						-- Left pane: Image + Keys
						{
							pane = 1,
							function()
								return {
									section = "terminal",
									cmd = get_image_cmd(),
									height = 20,
									padding = 1,
									ttl = 0, -- always re-run on refresh
								}
							end,
							{ section = "keys", gap = 1, padding = 1 },
						},
						-- Right pane: Recent + Projects + Git
						{
							pane = 2,
							{ icon = " ", title = "Recent Files", indent = 2, padding = 1 },
							{ section = "recent_files", indent = 2, padding = 1, limit = 5 },
							{ icon = " ", title = "Projects", indent = 2, padding = 1 },
							{ section = "projects", indent = 2, padding = 1, limit = 5 },
							{ icon = " ", title = "Git Status", indent = 2, padding = 1 },
							{
								section = "terminal",
								cmd = "git status --short --branch --show-stash",
								height = 5,
								padding = 1,
								ttl = 5 * 60,
								indent = 3,
							},
						},
					},
				},
			})

			-- Helper function to refresh the dashboard
			local function refresh_dashboard()
				Snacks.dashboard.update()
			end

			-- Create user commands for image cycling
			vim.api.nvim_create_user_command("SnacksDashboardImageNext", function()
				ImgManager.next()
				ImgManager.save_state()
				refresh_dashboard()
				vim.notify(
					string.format(
						"Image: %s (%d/%d)",
						ImgManager.get_current_name(),
						ImgManager.current_index,
						ImgManager.get_count()
					),
					vim.log.levels.INFO
				)
			end, { desc = "Cycle to next image" })

			vim.api.nvim_create_user_command("SnacksDashboardImagePrev", function()
				ImgManager.prev()
				ImgManager.save_state()
				refresh_dashboard()
				vim.notify(
					string.format(
						"Image: %s (%d/%d)",
						ImgManager.get_current_name(),
						ImgManager.current_index,
						ImgManager.get_count()
					),
					vim.log.levels.INFO
				)
			end, { desc = "Cycle to previous image" })

			vim.api.nvim_create_user_command("SnacksDashboardImageRandom", function()
				ImgManager.random()
				ImgManager.save_state()
				refresh_dashboard()
				vim.notify(
					string.format(
						"Image: %s (%d/%d)",
						ImgManager.get_current_name(),
						ImgManager.current_index,
						ImgManager.get_count()
					),
					vim.log.levels.INFO
				)
			end, { desc = "Jump to random image" })

			vim.api.nvim_create_user_command("SnacksDashboardImageName", function()
				vim.notify(
					string.format(
						"Current image: %s (%d/%d)",
						ImgManager.get_current_name(),
						ImgManager.current_index,
						ImgManager.get_count()
					),
					vim.log.levels.INFO
				)
			end, { desc = "Show current image name" })

			-- Toggle dashboard command
			vim.api.nvim_create_user_command("SnacksDashboard", function()
				Snacks.dashboard()
			end, { desc = "Open Snacks Dashboard" })

			-- Notification history command
			vim.api.nvim_create_user_command("NotificationHistory", function()
				Snacks.notifier.show_history()
			end, { desc = "Show notification history" })

			-- Dismiss all notifications
			vim.api.nvim_create_user_command("NotificationDismiss", function()
				Snacks.notifier.hide()
			end, { desc = "Dismiss all notifications" })

			-- Set snacks notifier as the default vim.notify
			vim.notify = Snacks.notifier.notify

			-- Show startup stats after lazy loads (like old alpha footer)
			vim.api.nvim_create_autocmd("User", {
				once = true,
				pattern = "LazyVimStarted",
				callback = function()
					local stats = require("lazy").stats()
					local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
					vim.defer_fn(function()
						vim.notify(
							string.format("⚡ Loaded %d/%d plugins in %sms", stats.loaded, stats.count, ms),
							vim.log.levels.INFO,
							{ title = "Startup" }
						)
					end, 100)
				end,
			})

			-- Check for plugin updates periodically and notify
			vim.api.nvim_create_autocmd("User", {
				pattern = "LazyCheck",
				callback = function()
					local ok, checker = pcall(require, "lazy.manage.checker")
					if ok and checker.updated and #checker.updated > 0 then
						vim.notify(
							string.format("󰏔 %d plugin update(s) available", #checker.updated),
							vim.log.levels.INFO,
							{ title = "Lazy" }
						)
					end
				end,
			})
		end,
		keys = {
			{
				"<leader>h",
				function()
					require("snacks").dashboard()
				end,
				desc = "Home (Dashboard)",
			},
			{ "<leader>An", "<cmd>SnacksDashboardImageNext<cr>", desc = "Next image" },
			{ "<leader>Ap", "<cmd>SnacksDashboardImagePrev<cr>", desc = "Previous image" },
			{ "<leader>Ar", "<cmd>SnacksDashboardImageRandom<cr>", desc = "Random image" },
			{ "<leader>Ai", "<cmd>SnacksDashboardImageName<cr>", desc = "Image info" },
			{
				"<leader>sn",
				function()
					require("snacks").notifier.show_history()
				end,
				desc = "Notification History",
			},
			{
				"<leader>sN",
				function()
					require("snacks").notifier.hide()
				end,
				desc = "Dismiss Notifications",
			},
		},
	},

	-- Web devicons
	{ "nvim-tree/nvim-web-devicons", lazy = true },
}
