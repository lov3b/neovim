local A = {}

A.new = function(terminal)
	local M = {}

	M.start_runner = function()
		local root = vim.fs.root(0, ".git") or vim.fn.getcwd()

		local script_path = nil
		for _, file_name in ipairs({ "run-project.lua", ".run-project.lua" }) do
			local path = root .. "/" .. file_name

			if vim.fn.filereadable(path) == 1 then
				script_path = path
				break
			end
		end
		if not script_path then
			vim.notify("No run-project.lua found in root", vim.log.levels.WARN)
			return
		end

		local cmd = string.format("nvim -l %q", script_path)
		vim.notify("Starting project runner: " .. vim.fn.fnamemodify(script_path, ":t"), vim.log.levels.INFO)
		terminal.send_command(cmd)
	end

	return M
end

return A
