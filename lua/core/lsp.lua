local mason        = require('mason')
local mason_lsp    = require('mason-lspconfig')
local lspconfig    = require('lspconfig')
local cmp_nvim_lsp = require('cmp_nvim_lsp')

-- Servers
local servers = { "ruff", "lua_ls", "rust_analyzer", "clangd", "ts_ls" }
mason.setup()
mason_lsp.setup {
  ensure_installed = servers,
}

-- LSP capabilities & on_attach
local capabilities = cmp_nvim_lsp.default_capabilities()
local on_attach = function(_, bufnr)
  local buf_map = function(keys, fn, desc)
    if desc then desc = 'LSP: ' .. desc end
    vim.keymap.set('n', keys, fn, { buffer = bufnr, desc = desc })
  end
  buf_map('gd', vim.lsp.buf.definition, 'Go to definition')
  buf_map('K',  vim.lsp.buf.hover,      'Hover docs')
  buf_map('<leader>rn', vim.lsp.buf.rename, 'Rename')
end

-- Setup each installed server
for _, name in ipairs(servers) do
  lspconfig[name].setup {
    on_attach    = on_attach,
    capabilities = capabilities,
  }
end
