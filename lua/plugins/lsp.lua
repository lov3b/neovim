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
		local mason_utils = require("core.mason")

		local servers = {
			"clangd",
			"nil_ls",
			"ts_ls",
			"jdtls",
			"rust_analyzer",
			"kotlin_language_server",
			"pyright",
			"bashls",
			"lua_ls",
			"texlab",
			"tinymist",
		}
		local mason_servers = vim.tbl_filter(function(server)
			return server ~= "nil_ls"
		end, servers)

		mason.setup({
			PATH = "append",
		})
		mason_lsp.setup({
			ensure_installed = mason_utils.missing(mason_servers),
		})

		local capabilities = cmp_nvim_lsp.default_capabilities()
		local on_attach = function(client, bufnr)
			local buf_map = function(keys, fn, desc)
				if desc then
					desc = "LSP: " .. desc
				end
				vim.keymap.set("n", keys, fn, { buffer = bufnr, desc = desc })
			end
			if client.name == "rust_analyzer" then
				vim.lsp.semantic_tokens.enable(false, { client_id = client.id })
				if client:supports_method("textDocument/inlayHint", bufnr) then
					vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
				end
			end
			buf_map("gd", vim.lsp.buf.definition, "Go to definition")
			buf_map("K", vim.lsp.buf.hover, "Hover docs")
			buf_map("<leader>rn", function()
				vim.lsp.buf.rename()
			end, "Rename")
		end

		for _, name in ipairs(servers) do
			local config = {
				on_attach = on_attach,
				capabilities = capabilities,
			}
			if name == "rust_analyzer" then
				config.settings = {
					["rust-analyzer"] = {
						inlayHints = {
							typeHints = {
								enable = true,
								hideInferredTypes = false,
							},
						},
					},
				}
			end
			vim.lsp.config(name, config)
			vim.lsp.enable(name)
		end
	end,
}
