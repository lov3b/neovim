return {
	"stevearc/oil.nvim",
	config = function()
		require("oil").setup({})
		vim.keymap.set("n", "<leader>-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

		vim.api.nvim_create_autocmd("User", {
			pattern = "OilActionsPost",
			callback = function(event)
				if event.data.actions[1].type == "move" then
					Snacks.rename.on_rename_file(event.data.actions[1].src_url, event.data.actions[1].dest_url)
				end
			end,
		})
	end,
}
