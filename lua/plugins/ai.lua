-- AI-powered development tools

return {
	-- Claude Code integration for Neovim
	{
		"coder/claudecode.nvim",
		dependencies = {
			"folke/snacks.nvim",
		},
		config = true,
		opts = {
			-- Terminal configuration
			terminal = {
				split_side = "right",
				split_width_percentage = 0.40,
				provider = "snacks", -- Use snacks.nvim for terminal
				auto_close = true,
			},
			-- Auto-start the WebSocket server for Claude Code CLI
			auto_start = true,
			-- Track selection for context
			track_selection = true,
			-- Don't auto-focus terminal after sending
			focus_after_send = false,
			-- Diff integration
			diff_opts = {
				auto_close_on_accept = true,
				vertical_split = true,
				open_in_current_tab = true,
			},
		},
		keys = {
			{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
			{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
			{ "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select model" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
			-- Quick toggle with Ctrl+,
			{ "<C-,>", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
		},
	},
}
