local null_ls = require('null-ls')
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.diagnostics.ruff,
  },
  on_attach = function(client)
    if client.supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = 0,
        callback = function() vim.lsp.buf.format({ async = false }) end,
      })
    end
  end,
})

