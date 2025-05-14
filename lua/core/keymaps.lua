local map = vim.keymap.set
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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

-- Telescope (deferred)
map('n','<leader>ff', function() require('telescope.builtin').find_files() end, {desc='Find files'})
map('n','<leader>fg', function() require('telescope.builtin').live_grep() end,  {desc='Live grep'})
map('n','<leader>fb', function() require('telescope.builtin').buffers() end,    {desc='Buffers'})
map('n','<leader>fh', function() require('telescope.builtin').help_tags() end,  {desc='Help tags'})
map('n','<leader>fp', function() require('telescope').extensions.projects.projects() end, {desc='Projects'})

-- Diagnostics
map('n','[d', vim.diagnostic.goto_prev, {desc='Prev diagnostic'})
map('n',']d', vim.diagnostic.goto_next, {desc='Next diagnostic'})
map('n','<leader>e', vim.diagnostic.open_float, {desc='Line diagnostics'})
map('n','<leader>q', vim.diagnostic.setloclist, {desc='Diagnostics list'})

-- Netrw
map('n', '<leader>x', '<cmd>Explore<CR>', {
  desc = 'Open Netrw Explorer',
})
