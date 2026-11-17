return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	dependencies = { "mason-org/mason.nvim" },
	config = function()
		local mason_utils = require("core.mason")
		local ensure_installed = {
			"stylua",
			"ruff",
			"prettier",
			"clang-format",
			"shfmt",
			"ktlint",
			"google-java-format",
			"latexindent",
			"codelldb",
			"debugpy",
			"typstyle",
			"tree-sitter-cli",
		}

		require("mason-tool-installer").setup({
			ensure_installed = mason_utils.missing(ensure_installed),
			run_on_start = true,
		})
	end,
}
