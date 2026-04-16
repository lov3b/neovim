return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		local languages = {
			"nix",
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
		}

		require("nvim-treesitter").setup({
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
					goto_next_start = {
						["]m"] = "@function.outer",
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
					},
				},
			},
		})
		require("nvim-treesitter.install").ensure_installed(languages)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = languages,
			callback = function(args)
				vim.treesitter.start(args.buf, args.match)
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
