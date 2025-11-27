local M = {}

M.state = {
	term_tab_id = nil,
	came_from = nil,
}

-- Ensure terminal stays at the end when ANY new tab is created
vim.api.nvim_create_autocmd("TabNew", {
	callback = function()
		-- If the terminal tab exists and is valid
		local exists_term = M.state.term_tab_id and vim.api.nvim_tabpage_is_valid(M.state.term_tab_id)
		if not exists_term then
			return
		end
		local term_tab_nr = vim.api.nvim_tabpage_get_number(M.state.term_tab_id)
		local total_tabs = vim.fn.tabpagenr("$")

		-- Move to end, if it's not in the end
		if term_tab_nr < total_tabs then
			vim.cmd(term_tab_nr .. "tabmove $")
		end
	end,
})

local function create_terminal()
	vim.cmd("tabnew")
	vim.cmd("terminal")

	local new_tab = vim.api.nvim_get_current_tabpage()
	local new_buf = vim.api.nvim_get_current_buf()

	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	vim.opt_local.signcolumn = "no"

	-- Close the terminal when we exit the shell
	vim.api.nvim_create_autocmd("TermClose", {
		buffer = new_buf,
		callback = function()
			-- Only close if the tab is still valid and we are inside it
			if vim.api.nvim_tabpage_is_valid(new_tab) then
				if #vim.api.nvim_tabpage_list_wins(new_tab) == 1 then
					vim.cmd("tabclose")
				else
					vim.cmd("bdelete!")
				end
			end
			M.state.term_tab_id = nil
		end,
	})

	return new_tab
end

M.toggle_terminal = function()
	local current_tab = vim.api.nvim_get_current_tabpage()

	local exists_term = M.state.term_tab_id and vim.api.nvim_tabpage_is_valid(M.state.term_tab_id)
	if not exists_term then
		M.state.came_from = current_tab
		M.state.term_tab_id = create_terminal()
		vim.cmd("startinsert")
		return
	end

	local in_terminal = current_tab == M.state.term_tab_id
	if in_terminal then
		-- We should go back
		vim.api.nvim_set_current_tabpage(M.state.came_from)
	else
		M.state.came_from = current_tab
		vim.api.nvim_set_current_tabpage(M.state.term_tab_id)
		vim.cmd("startinsert")
	end
end

return M
