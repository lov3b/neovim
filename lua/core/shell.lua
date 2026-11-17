-- prefer nushell on windows
if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
	local nu_path = vim.fn.expand("~/AppData/Local/Programs/nu/bin/nu.exe")
	-- executable() and filereadable() return 0 or 1, and 0 is truthy in Lua
	local nu_on_path = vim.fn.executable("nu") == 1

	if nu_on_path or vim.fn.filereadable(nu_path) == 1 then
		vim.opt.shell = nu_on_path and "nu" or nu_path
		vim.opt.shellcmdflag = "-c"
		vim.opt.shellquote = ""
		vim.opt.shellxquote = ""
	end
end
