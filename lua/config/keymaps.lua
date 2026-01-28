-- This file contains core mappings that don't depend on plugins
-- Plugin-specific mappings are defined in their respective plugin specs

local map = vim.keymap.set

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                            NAVIGATION                                     ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows
map("n", "<C-Up>", "<cmd>resize -2<CR>", { desc = "Resize window up" })
map("n", "<C-Down>", "<cmd>resize +2<CR>", { desc = "Resize window down" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Resize window left" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Resize window right" })

-- Buffer navigation
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                         BUFFER MANAGEMENT (<leader>b)                     ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

map("n", "<leader>bb", "<cmd>FzfLua buffers<CR>", { desc = "Switch buffer" })
map("n", "<leader>bc", "<cmd>bdelete<CR>", { desc = "Close buffer" })
map("n", "<leader>bC", "<cmd>bdelete!<CR>", { desc = "Force close buffer" })
map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "New buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bs", "<cmd>w<CR>", { desc = "Save buffer" })

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                           FIND/FILES (<leader>f)                          ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

map("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Find files" })
map("n", "<leader>fF", "<cmd>FzfLua files no_ignore=true hidden=true<CR>", { desc = "Find all files" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", { desc = "Find buffers" })
map("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Find text (grep)" })
map("n", "<leader>fh", "<cmd>FzfLua help_tags<CR>", { desc = "Find help" })
map("n", "<leader>fk", "<cmd>FzfLua keymaps<CR>", { desc = "Find keymaps" })
map("n", "<leader>fm", "<cmd>FzfLua marks<CR>", { desc = "Find marks" })
map("n", "<leader>fo", "<cmd>FzfLua oldfiles<CR>", { desc = "Find recent files" })
map("n", "<leader>fr", "<cmd>FzfLua registers<CR>", { desc = "Find registers" })
map("n", "<leader>fc", function()
	require("config.colorscheme").pick_colorscheme()
end, { desc = "Find colorschemes" })
map("n", "<leader>fC", "<cmd>FzfLua commands<CR>", { desc = "Find commands" })
map("n", "<leader>fw", "<cmd>FzfLua grep_cword<CR>", { desc = "Find word under cursor" })
map("n", "<leader>f/", "<cmd>FzfLua lgrep_curbuf<CR>", { desc = "Find in buffer" })
map("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<CR>", { desc = "Find diagnostics" })

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                              GIT (<leader>g)                              ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })
map("n", "<leader>gf", "<cmd>LazyGitCurrentFile<CR>", { desc = "LazyGit current file" })
map("n", "<leader>gb", "<cmd>FzfLua git_branches<CR>", { desc = "Git branches" })
map("n", "<leader>gc", "<cmd>FzfLua git_commits<CR>", { desc = "Git commits" })
map("n", "<leader>gC", "<cmd>FzfLua git_bcommits<CR>", { desc = "Git buffer commits" })
map("n", "<leader>gs", "<cmd>FzfLua git_status<CR>", { desc = "Git status" })
map("n", "<leader>gS", "<cmd>FzfLua git_stash<CR>", { desc = "Git stash" })

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                              LSP (<leader>l)                              ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
-- Note: Most LSP keymaps are defined in plugins/lsp.lua on_attach function
-- These are supplemental/fallback mappings

map("n", "<leader>li", "<cmd>LspInfo<CR>", { desc = "LSP info" })
map("n", "<leader>lI", "<cmd>Mason<CR>", { desc = "Mason info" })

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                           PACKAGES (<leader>p)                            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

map("n", "<leader>pp", "<cmd>Lazy<CR>", { desc = "Plugin manager" })
map("n", "<leader>pi", "<cmd>Lazy install<CR>", { desc = "Install plugins" })
map("n", "<leader>ps", "<cmd>Lazy sync<CR>", { desc = "Sync plugins" })
map("n", "<leader>pu", "<cmd>Lazy update<CR>", { desc = "Update plugins" })
map("n", "<leader>pc", "<cmd>Lazy clean<CR>", { desc = "Clean plugins" })
map("n", "<leader>pC", "<cmd>Lazy check<CR>", { desc = "Check for updates" })
map("n", "<leader>pl", "<cmd>Lazy log<CR>", { desc = "View log" })
map("n", "<leader>pr", "<cmd>Lazy restore<CR>", { desc = "Restore plugins" })
map("n", "<leader>pP", "<cmd>Lazy profile<CR>", { desc = "Profile" })
map("n", "<leader>ph", "<cmd>Lazy health<CR>", { desc = "Health check" })

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                        SEARCH/SESSION (<leader>s)                         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

map("n", "<leader>sc", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>sr", "<cmd>FzfLua resume<CR>", { desc = "Resume last search" })

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                           TERMINAL (<leader>t)                            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
-- Note: Main terminal keymaps are in plugins/tools.lua (toggleterm)

map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>", { desc = "Float terminal" })
map("n", "<leader>th", "<cmd>ToggleTerm direction=horizontal size=10<CR>", { desc = "Horizontal terminal" })
map("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<CR>", { desc = "Vertical terminal" })

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                           UI/TOGGLE (<leader>u)                           ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

map("n", "<leader>uc", function()
	require("config.colorscheme").pick_colorscheme()
end, { desc = "Change colorscheme" })
map("n", "<leader>ud", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })
map("n", "<leader>ul", "<cmd>set relativenumber!<CR>", { desc = "Toggle relative line numbers" })
map("n", "<leader>un", function()
	vim.o.number = not vim.o.number
end, { desc = "Toggle line numbers" })
map("n", "<leader>us", "<cmd>set spell!<CR>", { desc = "Toggle spell check" })
map("n", "<leader>uw", "<cmd>set wrap!<CR>", { desc = "Toggle word wrap" })
map("n", "<leader>ui", function()
	if vim.lsp.inlay_hint then
		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
	end
end, { desc = "Toggle inlay hints (global)" })

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                        DASHBOARD (Snacks) (<leader>A)                     ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

map("n", "<leader>Ah", "<cmd>SnacksDashboard<CR>", { desc = "Open Dashboard" })
map("n", "<leader>An", "<cmd>SnacksDashboardImageNext<CR>", { desc = "Next image" })
map("n", "<leader>Ap", "<cmd>SnacksDashboardImagePrev<CR>", { desc = "Previous image" })
map("n", "<leader>Ar", "<cmd>SnacksDashboardImageRandom<CR>", { desc = "Random image" })
map("n", "<leader>Ai", "<cmd>SnacksDashboardImageName<CR>", { desc = "Show image name" })

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                         WRITE/SAVE (<leader>w)                            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write (save) buffer" })

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                            WINDOWS (<leader>W)                            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

map("n", "<leader>Wc", "<cmd>close<CR>", { desc = "Close window" })
map("n", "<leader>Wh", "<cmd>split<CR>", { desc = "Horizontal split" })
map("n", "<leader>Wv", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "<leader>W=", "<C-w>=", { desc = "Equal window sizes" })
map("n", "<leader>Wq", "<cmd>wq<CR>", { desc = "Save and quit window" })
map("n", "<leader>Wo", "<cmd>only<CR>", { desc = "Close other windows" })
map("n", "<leader>Ww", "<C-w>w", { desc = "Switch window" })

-- Quick split shortcuts (AstroNvim style)
map("n", "|", "<cmd>vsplit<CR>", { desc = "Vertical split" })
map("n", "-", "<cmd>split<CR>", { desc = "Horizontal split" })

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                         DIAGNOSTICS NAVIGATION                            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                          STANDARD MAPPINGS                                ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- Better indenting (stay in visual mode)
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Note: Alt+hjkl line movement is handled by mini.move plugin (editor.lua)

-- Save/Quit shortcuts
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
map("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit all" })

-- Clear search highlight on Escape
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Better escape from insert mode
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- Center screen after jumps
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Yank to system clipboard
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clipboard" })
map("n", "<leader>Y", '"+Y', { desc = "Yank line to clipboard" })

-- Delete without yanking
map({ "n", "v" }, "<leader>D", '"_d', { desc = "Delete without yank" })

-- Replace word under cursor
map("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })

-- Quick access to frequently used commands
map("n", "<leader><leader>", "<cmd>FzfLua buffers<CR>", { desc = "Switch buffer" })
map("n", "<leader>/", "<cmd>FzfLua lgrep_curbuf<CR>", { desc = "Search in buffer" })

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                           LSP NAVIGATION (gX)                             ║
-- ╚══════════════════════════════════════════════════════════════════════════╝
-- Note: These are fallbacks; the actual LSP bindings are in plugins/lsp.lua

map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
map("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
map("n", "gy", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover documentation" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename symbol" })
