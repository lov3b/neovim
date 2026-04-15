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

		require("nvim-treesitter").setup({})
		require("nvim-treesitter").install(languages)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = languages,
			callback = function(args)
				vim.treesitter.start(args.buf, args.match)
				vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})

		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
				keymaps = {
					["af"] = "@function.outer",
					["if"] = "@function.inner",
				},
			},
			move = {
				set_jumps = true,
			},
		})

		vim.keymap.set({ "n", "x", "o" }, "]m", function()
			require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
		end)
		vim.keymap.set({ "n", "x", "o" }, "[m", function()
			require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
		end)
	end,
}
