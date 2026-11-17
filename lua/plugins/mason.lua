return {
	"mason-org/mason.nvim",
	config = function()
		require("mason").setup({
			-- Tools already on PATH (rustup, the system package manager) win
			-- over Mason's copies.
			PATH = "append",
		})

		local uninstalled = require("core.mason").uninstall_shadowed()
		if #uninstalled > 0 then
			vim.notify(
				"Mason: uninstalled, now provided by the system: " .. table.concat(uninstalled, ", "),
				vim.log.levels.INFO
			)
		end
	end,
}
