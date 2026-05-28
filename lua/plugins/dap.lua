return {
	"mfussenegger/nvim-dap",
	dependencies = {
		-- UI for DAP (stacks, watches, etc.)
		{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
		-- Virtual text (shows variable values inline)
		"theHamsta/nvim-dap-virtual-text",
		-- Bridges Mason and DAP
		"jay-babu/mason-nvim-dap.nvim",
	},
	keys = {
		{
			"<F5>",
			function()
				require("dap").continue()
			end,
			desc = "Debug: Start/Continue",
		},
		{
			"<F1>",
			function()
				require("dap").step_into()
			end,
			desc = "Debug: Step Into",
		},
		{
			"<F2>",
			function()
				require("dap").step_over()
			end,
			desc = "Debug: Step Over",
		},
		{
			"<F3>",
			function()
				require("dap").step_out()
			end,
			desc = "Debug: Step Out",
		},
		{
			"<leader>b",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Debug: Toggle Breakpoint",
		},
		{
			"<leader>B",
			function()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end,
			desc = "Debug: Set Conditional Breakpoint",
		},
		{
			"<leader>du",
			function()
				require("dapui").toggle()
			end,
			desc = "Debug: Toggle UI",
		},
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local mason_utils = require("core.mason")

		require("mason-nvim-dap").setup({
			automatic_installation = true,
			handlers = {},
			ensure_installed = mason_utils.missing({
				"codelldb", -- C/C++/Rust
				"debugpy", -- Python
			}),
		})

		-- Resolve python debug adapter at debug-time: prefer the
		-- debugpy-adapter binary (Mason or otherwise on PATH), fall
		-- back to running debugpy as a python module (Arch's
		-- python-debugpy ships only the module).
		dap.adapters.python = function(cb, _)
			local cmd, args
			if vim.fn.executable("debugpy-adapter") == 1 then
				cmd, args = "debugpy-adapter", {}
			else
				cmd, args = "python", { "-m", "debugpy.adapter" }
			end
			cb({ type = "executable", command = cmd, args = args })
		end

		dap.configurations.python = dap.configurations.python
			or {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					pythonPath = function()
						return vim.fn.exepath("python")
					end,
				},
			}

		dapui.setup()

		-- Auto-open UI when debugging starts
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		-- Make breakpoints look nicer
		vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
		vim.fn.sign_define(
			"DapBreakpointCondition",
			{ text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
		)
		vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
	end,
}
