-- prefer nushell on windows
if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
	local nu_path = vim.fn.expand("~/AppData/Local/Programs/nu/bin/nu.exe")
	local use_nu = vim.fn.executable("nu") or vim.fn.filereadable(nu_path)

	if use_nu then
		vim.opt.shell = vim.fn.executable("nu") and "nu" or nu_path
		vim.opt.shellcmdflag = "-c"
		vim.opt.shellquote = ""
		vim.opt.shellxquote = ""
	end
end
