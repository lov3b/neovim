return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	dependencies = { "williamboman/mason.nvim" },
	config = function()
		local ensure_installed = {
			"stylua",
			"ruff",
			"prettier",
			"rustfmt",
			"clang-format",
			"shfmt",
			"ktlint",
			"google-java-format",
			"latexindent",
			"codelldb",
			"debugpy",
			"typstyle",
		}

		require("mason").setup()
		require("mason-tool-installer").setup({
			ensure_installed = ensure_installed,
			run_on_start = true,
		})
	end,
}
