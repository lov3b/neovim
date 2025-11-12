require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black", "isort" },

		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		markdown = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		scss = { "prettier" },
		yaml = { "prettier" },

		rust = { "rustfmt" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		kotlin = { "ktlint" },
		java = { "google-java-format" },
	},

	format_on_save = {
		timeout_ms = 2000,
		lsp_fallback = true,
	},
})
