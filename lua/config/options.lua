-- Options extracted from astrocore.lua
local opt = vim.opt

-- Line numbers
opt.relativenumber = true
opt.number = true

-- Editing
opt.spell = true
opt.wrap = false
opt.signcolumn = "yes"

-- Tabs & Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Appearance
opt.termguicolors = true
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.fillchars = { eob = " " } -- Remove ~ from empty lines

-- Split behavior
opt.splitright = true
opt.splitbelow = true

-- Undo & Backup
opt.undofile = true
opt.swapfile = false
opt.backup = false

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- Clipboard
opt.clipboard = "unnamedplus"

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Diagnostics
vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	signs = true,
	update_in_insert = false,
	severity_sort = true,
})
