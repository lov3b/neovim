local o = vim.opt

-- UI
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.termguicolors = true

-- Editing
o.clipboard = "unnamedplus"
o.mouse = "a"
o.breakindent = true
o.wrap = false

-- Search
o.ignorecase = true
o.smartcase = true
o.hlsearch = false
o.incsearch = true

-- Tabstop
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true

-- Performance
o.updatetime = 100
o.timeoutlen = 300
o.completeopt = { "menuone", "noselect" }

-- Max chars
o.colorcolumn = "100"

-- Backup
local undordir_base = os.getenv("XDG_DATA_HOME") or ((os.getenv("HOME") or os.getenv("USERPROFILE")) .. "/.vim")
o.undodir = undordir_base .. "/undodir"
o.swapfile = false
o.backup = false
o.undofile = true

-- Autoread from changed file
o.autoread = true

-- Reload file when changed externally
vim.api.nvim_create_augroup("AutoReload", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	group = "AutoReload",
	pattern = "*",
	command = "checktime",
})
-- Notification when file changes
vim.api.nvim_create_autocmd("FileChangedShellPost", {
	group = "AutoReload",
	pattern = "*",
	callback = function()
		vim.notify("File changed on disk. Buffer reloaded!", vim.log.levels.INFO)
	end,
})
