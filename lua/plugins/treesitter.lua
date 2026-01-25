return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"lua",
				"python",
				"javascript",
				"typescript",
				"go",
				"rust",
				"c",
				"cpp",
				"vim",
				"java",
				"kotlin",
				"typst",
			},
			highlight = { enable = true },
			indent = { enable = true },
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = "@function.outer",
						["if"] = "@function.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = { ["]m"] = "@function.outer" },
					goto_previous_start = { ["[m"] = "@function.outer" },
				},
			},
		})
	end,
}
