-- ============================================================================
-- NVIM-LINT CODE LINTER
-- ============================================================================
-- nvim-lint: Asynchronous linting framework for Neovim
--
-- Features:
--   - Runs linters on files to check for style issues and errors
--   - Non-blocking (async) operation - doesn't freeze the editor
--   - Integrates with multiple linters per language
--   - Works alongside LSP diagnostics
--   - Can be triggered on file open, after write, or manually
--   - Shows results in the location list or as virtual text
--
-- Linters vs LSP:
--   - LSP: Type checking, semantic analysis
--   - Linters: Code style, convention checking
--   - Both complement each other for comprehensive code quality
--
-- Repo: https://github.com/mfussenegger/nvim-lint
-- ============================================================================

return {
	"mfussenegger/nvim-lint",
	-- Load on file open and when creating new files
	-- This ensures linting is ready when you start editing
	event = { "BufReadPre", "BufNewFile" },

	-- Configuration function: runs after plugin is loaded
	config = function()
		-- Load the lint module
		local lint = require("lint")

		-- Define which linters to use for each filetype
		-- Map: filetype -> list of linter names
		-- Multiple linters can be used per filetype (they'll all run)
		lint.linters_by_ft = {
			-- Use markdownlint for Markdown files
			-- Checks for style issues like:
			-- - Proper heading hierarchy
			-- - Code block formatting
			-- - Link and image syntax
			-- markdown = { "markdownlint" },
		}
		-- You can add more filetypes here, e.g.:
		-- python = { 'pylint', 'flake8' },
		-- javascript = { 'eslint' },
		-- lua = { 'luacheck' },

		-- Create an autocommand group for linting
		-- Groups allow us to manage multiple related autocommands
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		-- Set up automatic linting on certain events
		vim.api.nvim_create_autocmd(
			{ "BufEnter", "BufWritePost", "InsertLeave" }, -- Trigger events
			{
				group = lint_augroup,
				-- Callback function that runs when the events occur
				callback = function()
					-- Only lint if the buffer is modifiable
					-- Skip read-only files, special buffers, etc.
					if vim.bo.modifiable then
						-- Try to lint the current file
						-- Gracefully handles cases where no linter is configured
						lint.try_lint()
					end
				end,
			}
		)
	end,
}
