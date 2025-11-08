local null_ls = require("null-ls")

local f = null_ls.builtins.formatting
local d = null_ls.builtins.diagnostics

null_ls.setup({
	sources = {
		-- Lua
		f.stylua,
		-- Python: choose EITHER ruff_format OR black+isort
		f.black,
		f.isort,
		-- JS/TS/JSON/MD/HTML/CSS/YAML
		f.prettier,
		-- Go
		f.gofumpt,
		f.goimports,
		-- Rust
		f.rustfmt,
		-- C/C++
		f.clang_format,
		-- Shell
		f.shfmt,
		-- Kotlin
		f.ktlint,
		-- Java
		f.google_java_format,
	},

	on_attach = function(client, bufnr)
		-- Prefer null-ls for formatting; avoid dueling formatters
		if client.supports_method("textDocument/formatting") then
			local grp = vim.api.nvim_create_augroup("NullLsFormatOnSave", { clear = false })
			vim.api.nvim_clear_autocmds({ group = grp, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = grp,
				buffer = bufnr,
				callback = function()
					-- Skip giant files for speed
					local max = 1024 * 1024
					local name = vim.api.nvim_buf_get_name(bufnr)
					local ok, stats = pcall(vim.loop.fs_stat, name)
					if ok and stats and stats.size > max then
						return
					end

					vim.lsp.buf.format({
						async = false,
						timeout_ms = 2000,
						filter = function(fmt_client)
							return fmt_client.name == "null-ls"
						end,
					})
				end,
			})
		end
	end,
})
