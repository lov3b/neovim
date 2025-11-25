-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core
require("core.shell")
require("core.options")
require("core.keymaps")

-- Bootstrap Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Monkeypatch for project.nvim
if vim.version().minor > 10 then
	vim.lsp.buf_get_clients = vim.lsp.get_clients
end

-- Setup Lazy
require("lazy").setup("plugins", {
	change_detection = { notify = false },
})
