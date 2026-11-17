return {
	"stevearc/oil.nvim",
	config = function()
		require("oil").setup({})
		vim.keymap.set("n", "<leader>-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

		vim.api.nvim_create_autocmd("User", {
			pattern = "OilActionsPost",
			callback = function(event)
				-- Saving without changes gives an empty action list
				for _, action in ipairs(event.data.actions) do
					if action.type == "move" then
						Snacks.rename.on_rename_file(action.src_url, action.dest_url)
					end
				end
			end,
		})
	end,
}
