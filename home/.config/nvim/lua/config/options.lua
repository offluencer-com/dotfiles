local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Real truecolor, actual pywal colorscheme plugin handles the palette
-- (see lua/plugins/colorscheme.lua) - this is correct, don't disable it.
opt.termguicolors = true

-- netrw is dead weight now that nvim-tree exists
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- UI
opt.number = true
opt.relativenumber = false
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.laststatus = 3 -- one statusline for the whole window

-- Editing
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.clipboard = "unnamedplus"
opt.mouse = "a"

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300
opt.lazyredraw = false -- keep false; true breaks some plugin UIs and rarely helps on modern nvim
opt.synmaxcol = 300

-- Persistence
opt.undofile = true
opt.swapfile = false
opt.backup = false

-- Coding default: no wrap, hard textwidth off (autocmds.lua overrides per filetype)
opt.wrap = false
opt.linebreak = false
opt.textwidth = 0
opt.formatoptions = "cqj" -- auto-wrap comments, allow gq, remove comment leader on join

-- Only highlight search results while actively typing the search, not after
opt.hlsearch = false
local search_group = vim.api.nvim_create_augroup("SearchHighlight", { clear = true })
vim.api.nvim_create_autocmd("CmdlineEnter", { group = search_group, pattern = "/,\\?", command = "set hlsearch" })
vim.api.nvim_create_autocmd("CmdlineLeave", { group = search_group, pattern = "/,\\?", command = "set nohlsearch" })
