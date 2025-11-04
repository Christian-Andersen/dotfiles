-- ============================================================================
-- TOKYONIGHT COLORSCHEME
-- ============================================================================
-- tokyonight.nvim: Beautiful and modern colorscheme inspired by Tokyo Night
--
-- Features:
--   - Three color variants: night (dark), storm (darker), moon (mid)
--   - Beautiful syntax highlighting
--   - Works well with Terminal UI plugins (neo-tree, telescope, etc.)
--   - Customizable appearance and contrast
--   - Carefully curated colors for better readability
--
-- Variants:
--   - tokyonight-night: Default dark variant (recommended)
--   - tokyonight-storm: Even darker variant
--   - tokyonight-moon: Mid-tone variant
--
-- Repo: https://github.com/folke/tokyonight.nvim
-- ============================================================================

return {
	"folke/tokyonight.nvim",
	-- High priority: ensure this loads before other plugins
	-- Colorscheme should be loaded early to apply colors correctly
	priority = 1000,
	config = function()
		-- Configure tokyonight before setting it as colorscheme
		require("tokyonight").setup({
			-- Style configuration
			styles = {
				-- Don't use italic for comments (less common preference)
				-- Set to italic = true to enable italicized comments
				comments = { italic = false },
			},
		})

		-- Set the active colorscheme to tokyonight-night (dark mode)
		-- Other options: 'tokyonight-storm' or 'tokyonight-moon'
		vim.cmd.colorscheme("tokyonight-night")
	end,
}
