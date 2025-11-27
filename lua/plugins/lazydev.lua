return {
	"folke/lazydev.nvim",
	ft = "lua",
	opts = {
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
		enabled = function(root_dir)
			local bufname = vim.api.nvim_buf_get_name(0)

			return (
				bufname:match("run%-project%.lua$") -- The project runner script
				or bufname:find(vim.fn.stdpath("config")) -- The nvim config
				or bufname:find(vim.fn.stdpath("data"), 1, true) -- The plugins
			)
		end,
	},
}
