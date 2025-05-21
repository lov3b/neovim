local map = vim.keymap.set

-- clear <Space>
map({'n','v'}, '<Space>', '<Nop>', { silent = true })

-- Yank highlight
vim.api.nvim_create_augroup('YankHL', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = 'YankHL', pattern = '*',
  callback = function() vim.highlight.on_yank() end,
})

-- Buffer navG
map('n','<leader>bn','<cmd>bnext<CR>',{desc='Next buffer'})
map('n','<leader>bp','<cmd>bprevious<CR>',{desc='Prev buffer'})

-- Window nav
map('n','<C-h>','<C-w>h',{desc='Left window'})
map('n','<C-j>','<C-w>j',{desc='Below window'})
map('n','<C-k>','<C-w>k',{desc='Above window'})
map('n','<C-l>','<C-w>l',{desc='Right window'})

-- Diagnostics
map('n','[d', vim.diagnostic.goto_prev, {desc='Prev diagnostic'})
map('n',']d', vim.diagnostic.goto_next, {desc='Next diagnostic'})
map('n','<leader>e', vim.diagnostic.open_float, {desc='Line diagnostics'})
map('n','<leader>q', vim.diagnostic.setloclist, {desc='Diagnostics list'})

-- Netrw
map('n', '<leader>x', vim.cmd.Ex, { desc = 'Open Netrw Explorer' })

-- Yank entire buffer
map("n", "<leader>y", function()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	vim.fn.setreg("+", lines, "l")
end, { desc = "Yank entire buffer to clipboard without moving cursor" })

-- Paste to entire buffer
map("n", "<leader>p", function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local cb = vim.fn.getreg("+", 1, true)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, cb)
  row = math.min(row, #cb)
  vim.api.nvim_win_set_cursor(0, { row, col })
end, { desc = "Replace entire buffer with clipboard without moving cursor" })


-- Paste, but not remove the paste buffer
map("x", "<leader>p", "\"_dP")
