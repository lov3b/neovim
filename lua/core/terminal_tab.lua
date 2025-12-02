local M = {}

M.state = {
	term_tab_id = nil,
	term_buf_id = nil,
	came_from = nil,
}

-- Ensure terminal stays at the end when ANY new tab is created
vim.api.nvim_create_autocmd("TabNew", {
	callback = function()
		local exists_term = M.state.term_tab_id and vim.api.nvim_tabpage_is_valid(M.state.term_tab_id)
		if not exists_term then
			return
		end
		local term_tab_nr = vim.api.nvim_tabpage_get_number(M.state.term_tab_id)
		local total_tabs = vim.fn.tabpagenr("$")

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

	M.state.term_buf_id = new_buf

	vim.opt_local.number = false
	vim.opt_local.relativenumber = false
	vim.opt_local.signcolumn = "no"

	vim.api.nvim_create_autocmd("TermClose", {
		buffer = new_buf,
		callback = function()
			if vim.api.nvim_tabpage_is_valid(new_tab) then
				if #vim.api.nvim_tabpage_list_wins(new_tab) == 1 then
					vim.cmd("tabclose")
				else
					vim.cmd("bdelete!")
				end
			end
			-- Clean up state
			M.state.term_tab_id = nil
			M.state.term_buf_id = nil
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
		if M.state.came_from and vim.api.nvim_tabpage_is_valid(M.state.came_from) then
			vim.api.nvim_set_current_tabpage(M.state.came_from)
		else
			vim.cmd("tabnext #")
		end
	else
		M.state.came_from = current_tab
		vim.api.nvim_set_current_tabpage(M.state.term_tab_id)
		vim.cmd("startinsert")
	end
end

M.send_command = function(cmd_text)
	local exists_term = M.state.term_tab_id and vim.api.nvim_tabpage_is_valid(M.state.term_tab_id)
	if not exists_term then
		M.state.came_from = vim.api.nvim_get_current_tabpage()
		M.state.term_tab_id = create_terminal()
	end

	vim.api.nvim_set_current_tabpage(M.state.term_tab_id)
	vim.cmd("tabmove $")

	-- This assertion failed before because term_buf_id was nil
	assert(M.state.term_buf_id and vim.api.nvim_buf_is_valid(M.state.term_buf_id), "Terminal buffer invalid")

	local job_id = vim.b[M.state.term_buf_id].terminal_job_id
	assert(job_id, "Terminal didn't return a job-id")

	if job_id then
		vim.api.nvim_chan_send(job_id, "\x03") -- Interrupt previous job

		vim.defer_fn(function()
			vim.api.nvim_chan_send(job_id, cmd_text .. "\n")
			vim.cmd("normal! G")
		end, 50)
	end
end

return M
