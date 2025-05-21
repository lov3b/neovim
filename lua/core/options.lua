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
o.undofile    = true

-- Search
o.ignorecase = true
o.smartcase  = true
o.hlsearch   = false

-- Tabstop
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true

-- Performance
o.updatetime  = 250
o.timeoutlen  = 300
o.completeopt = { 'menuone', 'noselect' }
