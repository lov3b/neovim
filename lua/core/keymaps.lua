local terminal = require("core.terminal_tab")
local Runner = require("core.runner")

local map = vim.keymap.set

-- clear <Space>
map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Yank highlight
vim.api.nvim_create_augroup("YankHL", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	group = "YankHL",
	pattern = "*",
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Buffer navG
map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Prev buffer" })

-- Window nav
map("n", "<C-h>", "<C-w>h", { desc = "Left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Below window" })
map("n", "<C-k>", "<C-w>k", { desc = "Above window" })
map("n", "<C-l>", "<C-w>l", { desc = "Right window" })

-- Diagnostics
map("n", "<leader>0", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
map("n", "<leader>+", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics list" })

-- Remove arrows
vim.keymap.set("n", "<up>", "<nop>")
vim.keymap.set("n", "<down>", "<nop>")
vim.keymap.set("i", "<up>", "<nop>")
vim.keymap.set("i", "<down>", "<nop>")
vim.keymap.set("i", "<left>", "<nop>")
vim.keymap.set("i", "<right>", "<nop>")
-- let the left and right arrows be useful: they can switch buffers
vim.keymap.set("n", "<left>", ":bp<cr>")
vim.keymap.set("n", "<right>", ":bn<cr>")

-- quick-save
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>")

-- Yank entire buffer
map("n", "<leader>y", function()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	vim.cmd("%yank +")
	vim.api.nvim_win_set_cursor(0, { row, col })
end, { desc = "Yank entire buffer to clipboard" })

-- Paste to entire buffer
map("n", "<leader>p", function()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local cb = vim.fn.getreg("+", 1, true)
	vim.api.nvim_buf_set_lines(0, 0, -1, false, cb)
	row = math.min(row, #cb)
	vim.api.nvim_win_set_cursor(0, { row, col })
end, { desc = "Replace entire buffer with clipboard without moving cursor" })

-- Paste, but not remove the paste buffer
--map("x", "<leader>p", '"_dP')

vim.keymap.set("n", "<leader>F", function()
	require("conform").format({ async = false, timeout_ms = 2000 })
end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader>fn", function()
	local dir = vim.fn.expand("%:p:h")
	local path = vim.fn.input("New file: ", dir .. "/", "file")
	if path == "" then
		return
	end
	vim.cmd("edit " .. vim.fn.fnameescape(path))
end, { desc = "New file beside current" })

vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("MkDirOnSave", { clear = true }),
	callback = function(args)
		local d = vim.fn.fnamemodify(args.match, ":p:h")
		if vim.fn.isdirectory(d) == 0 then
			vim.fn.mkdir(d, "p")
		end
	end,
})
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

map("v", "<leader>h", function()
	vim.cmd('noautocmd normal! "vy')
	local text = vim.fn.getreg("v")

	text = vim.fn.escape(text, [[\/.*$^~[]])

	-- Set search register and enable highlighting
	vim.fn.setreg("/", "\\V" .. text)
	vim.opt.hlsearch = true
end, { desc = "Highlight all occurrences of selection" })

map("n", "<leader>h", function()
	vim.opt.hlsearch = false
end, { desc = "Clear search highlighting" })

vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})

map("n", "<leader>t", terminal.toggle_terminal, { desc = "Toggle Terminal Tab" })

local runner = Runner.new(terminal)
map("n", "<leader>rp", runner.start_runner, { desc = "Execute project runner lua script" })
