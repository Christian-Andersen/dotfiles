-- ============================================================================
-- CONFORM CODE FORMATTER
-- ============================================================================
-- conform.nvim: A lightweight and extensible code formatter
--
-- Features:
--   - Supports multiple formatters per language
--   - Format on save (can be disabled per filetype)
--   - LSP formatter fallback
--   - Async formatting to avoid blocking the editor
--   - Easy to configure and extend
--
-- Repo: https://github.com/stevearc/conform.nvim
-- ============================================================================

return {
	"stevearc/conform.nvim",
	-- Load on BufWritePre (before writing buffer to file)
	-- This enables format-on-save functionality
	event = { "BufWritePre" },
	-- Also load when :ConformInfo command is used
	-- Useful for checking formatter status without triggering lazy loading
	cmd = { "ConformInfo" },

	-- Keybindings for manual formatting
	keys = {
		{
			-- Leader+f maps to format the entire buffer
			"<leader>f",
			function()
				-- async = true: format without blocking the UI
				-- lsp_format = 'fallback': use LSP formatter if no formatter is configured
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "", -- Works in normal, insert, visual modes
			desc = "[F]ormat buffer",
		},
		{
			"<C-s>",
			function()
				require("conform").format({ lsp_format = "fallback" })
				vim.cmd("w")
			end,
			mode = { "n", "i", "x" },
			desc = "Format and Save",
		},
	},

	-- Configuration options
	opts = {
		-- Don't show error notifications if formatting fails
		notify_on_error = false,

		-- Define which formatters to use for each filetype
		formatters_by_ft = {
			-- Use stylua (Lua formatter) for Lua files
			lua = { "stylua" },
			-- Use prettierd for web-related files
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			javascriptreact = { "prettierd" },
			typescriptreact = { "prettierd" },
			json = { "prettierd" },
			css = { "prettierd" },
			scss = { "prettierd" },
			html = { "prettierd" },
			-- Use shfmt for shell scripts
			sh = { "shfmt" },
			bash = { "shfmt" },
			-- Use clang-format for C/C++
			c = { "clang-format" },
			cpp = { "clang-format" },
			-- Use sql-formatter for SQL
			sql = { "sql-formatter" },
		},
	},
}
