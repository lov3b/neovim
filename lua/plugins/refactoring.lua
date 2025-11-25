return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("refactoring").setup({})
		require("telescope").load_extension("refactoring")
	end,
	keys = {
		{
			"<leader>re",
			function()
				require("refactoring").refactor("Extract Function")
			end,
			mode = "x",
			desc = "Refactor: Extract Function",
		},
		{
			"<leader>rF",
			function()
				require("refactoring").refactor("Extract Function To File")
			end,
			mode = "x",
			desc = "Refactor: Extract Function To File",
		},
		{
			"<leader>rv",
			function()
				require("refactoring").refactor("Extract Variable")
			end,
			mode = "x",
			desc = "Refactor: Extract Variable",
		},

		{
			"<leader>rb",
			function()
				require("refactoring").refactor("Extract Block")
			end,
			mode = "n",
			desc = "Refactor: Extract Block",
		},
		{
			"<leader>rB",
			function()
				require("refactoring").refactor("Extract Block To File")
			end,
			mode = "n",
			desc = "Refactor: Extract Block To File",
		},

		{
			"<leader>rr",
			function()
				require("telescope").extensions.refactoring.refactors()
			end,
			mode = { "n", "x" },
			desc = "Refactor: Select Refactor (Telescope)",
		},
	},
}
