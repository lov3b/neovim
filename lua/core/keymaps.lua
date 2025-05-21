local map = vim.keymap.set

-- clear <Space>
map({'n','v'}, '<Space>', '<Nop>', { silent = true })

-- Yank highlight
vim.api.nvim_create_augroup('YankHL', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = 'YankHL', pattern = '*',
  callback = function() vim.highlight.on_yank() end,
})

-- Buffer nav
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
map('n', '<leader>x', '<cmd>Explore<CR>', {
  desc = 'Open Netrw Explorer',
})
