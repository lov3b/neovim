local o = vim.opt

-- UI
o.number = true
o.relativenumber = true
o.signcolumn = 'yes'
o.termguicolors = true

-- Editing
o.clipboard = 'unnamedplus'
o.mouse     = 'a'
o.breakindent = true
o.wrap = false

-- Search
o.ignorecase = true
o.smartcase  = true
o.hlsearch   = false
o.incsearch = true

-- Tabstop
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true

-- Performance
o.updatetime  = 100
o.timeoutlen  = 300
o.completeopt = { 'menuone', 'noselect' }

-- Max chars
o.colorcolumn = "100"

-- Backup
local undordir_base = os.getenv("XDG_DATA_HOME") 
             or (os.getenv("HOME") .. "/.vim")
o.undodir = undordir_base .. "/undodir"
o.swapfile = false
o.backup = false
o.undofile = true
