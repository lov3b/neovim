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

-- Filetypes that get treesitter highlighting and indentation. The React
-- filetypes are not parser names: javascriptreact uses the javascript parser
-- and typescriptreact uses tsx.
local filetypes = vim.list_extend({ "javascriptreact", "typescriptreact" }, languages)

-- Installed but never started here: tsx is reached through its filetype, the
-- rest are injected by Snacks (picker, image rendering).
local parsers = vim.list_extend({ "tsx", "regex", "latex", "html", "css" }, languages)

local function map_select(keys, capture)
	vim.keymap.set({ "x", "o" }, keys, function()
		require("nvim-treesitter-textobjects.select").select_textobject(capture, "textobjects")
	end, { desc = "Select " .. capture })
end

local function map_move(keys, method, capture)
	vim.keymap.set({ "n", "x", "o" }, keys, function()
		require("nvim-treesitter-textobjects.move")[method](capture, "textobjects")
	end, { desc = method .. " " .. capture })
end

return {
	{
		-- `master` is frozen and does not support Neovim 0.12; `main` is the
		-- rewrite, which compiles parsers with the tree-sitter CLI (installed
		-- through Mason, see mason-tools.lua).
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install(parsers)

			vim.api.nvim_create_autocmd("FileType", {
				pattern = filetypes,
				callback = function(args)
					-- A parser that is still compiling on first launch must
					-- not break opening the file.
					if not pcall(vim.treesitter.start, args.buf) then
						return
					end
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		lazy = false,
		config = function()
			require("nvim-treesitter-textobjects").setup({
				select = { lookahead = true },
				move = { set_jumps = true },
			})

			map_select("af", "@function.outer")
			map_select("if", "@function.inner")
			map_move("]m", "goto_next_start", "@function.outer")
			map_move("[m", "goto_previous_start", "@function.outer")
		end,
	},
}
