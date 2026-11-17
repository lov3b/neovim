-- The filetypes refactoring.nvim ships queries for. The keymaps exist only in
-- these buffers, so the plugin is never loaded for anything else.
local supported_filetypes = {
	"c",
	"cpp",
	"cs",
	"go",
	"java",
	"javascript",
	"javascriptreact",
	"kotlin",
	"lua",
	"php",
	"ps1",
	"python",
	"ruby",
	"typescript",
	"typescriptreact",
	"vim",
}

local function map_refactor(keys, method, desc)
	return {
		keys,
		function()
			return require("refactoring")[method]()
		end,
		mode = { "n", "x" },
		ft = supported_filetypes,
		expr = true,
		desc = "Refactor: " .. desc,
	}
end

return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		-- Only needed on Neovim 0.12; 0.13 ships vim.async.
		"lewis6991/async.nvim",
	},
	-- The refactors are operators: in normal mode they wait for a motion or
	-- textobject, in visual mode they act on the selection.
	keys = {
		map_refactor("<leader>re", "extract_func", "Extract Function"),
		map_refactor("<leader>rF", "extract_func_to_file", "Extract Function To File"),
		map_refactor("<leader>rv", "extract_var", "Extract Variable"),
		{
			"<leader>rr",
			function()
				require("refactoring").select_refactor()
			end,
			mode = { "n", "x" },
			ft = supported_filetypes,
			desc = "Refactor: Select Refactor",
		},
	},
}
