-- ============================================================================
-- Options — comfort for coding and long-form writing
-- ============================================================================

local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.termguicolors = true
opt.background = "dark"
opt.laststatus = 3
opt.showmode = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.pumheight = 12
opt.cmdheight = 1
opt.winborder = "rounded"

-- Indent (default; FileType autocmds override per language)
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true
opt.breakindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.inccommand = "split"

-- Editing comfort
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.updatetime = 200
opt.timeoutlen = 400
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.splitright = true
opt.splitbelow = true
opt.confirm = true -- quit with unsaved buffers → ask
opt.virtualedit = "block"
opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
opt.shortmess:append("c")
opt.fillchars = { eob = " ", fold = " ", foldopen = "▾", foldclose = "▸" }

-- Wrapping: off for code; prose FileTypes turn wrap on
opt.wrap = false
opt.linebreak = true
opt.smoothscroll = true

-- Files / encoding
opt.fileencoding = "utf-8"
opt.conceallevel = 2 -- nice markdown / org concealment
opt.concealcursor = ""

-- Persistent undo dir
local undodir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undodir, "p")
opt.undodir = undodir
