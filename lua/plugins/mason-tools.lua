return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	dependencies = { "williamboman/mason.nvim" },
	config = function()
		local mason_utils = require("core.mason")
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
			ensure_installed = mason_utils.missing(ensure_installed),
			run_on_start = true,
		})
	end,
}
