-- ============================================================================
-- GRUG-FAR: SEARCH AND REPLACE
-- ============================================================================
-- grug-far.nvim: A powerful search and replace tool with a friendly UI
--
-- Features:
--   - Project-wide search and replace
--   - Live preview of changes
--   - Support for regular expressions
--   - Filter by file patterns or directories
--   - Fast and intuitive interface
--
-- Repo: https://github.com/MagicDuck/grug-far.nvim
-- ============================================================================

return {
	"MagicDuck/grug-far.nvim",
	opts = {
		-- Maximum width of the header (helps on smaller screens)
		headerMaxWidth = 80,
	},
	keys = {
		{
			"<leader>sR",
			function()
				require("grug-far").open()
			end,
			desc = "[S]earch and [R]eplace (Grug-far)",
		},
	},
}
