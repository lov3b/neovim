return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		local mason = require("mason")
		local mason_lsp = require("mason-lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local servers = {
			"clangd",
			"rust_analyzer",
			"ts_ls",
			"jdtls",
			"kotlin_language_server",
			"pyright",
			"bashls",
			"lua_ls",
		}

		mason.setup()
		mason_lsp.setup({
			ensure_installed = servers,
		})

		local capabilities = cmp_nvim_lsp.default_capabilities()
		local on_attach = function(_, bufnr)
			local buf_map = function(keys, fn, desc)
				if desc then
					desc = "LSP: " .. desc
				end
				vim.keymap.set("n", keys, fn, { buffer = bufnr, desc = desc })
			end
			buf_map("gd", vim.lsp.buf.definition, "Go to definition")
			buf_map("K", vim.lsp.buf.hover, "Hover docs")
			buf_map("<leader>rn", function()
				vim.lsp.buf.rename()
			end, "Rename")
		end

		for _, name in ipairs(servers) do
			vim.lsp.config(name, {
				on_attach = on_attach,
				capabilities = capabilities,
			})
			vim.lsp.enable(name)
		end
	end,
}
