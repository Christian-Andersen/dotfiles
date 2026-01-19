-- ============================================================================
-- THEMES & COLORSCHEMES
-- ============================================================================
-- A collection of popular and aesthetic themes for Neovim.
--
-- Themes included:
--   - Tokyo Night: A clean, dark theme that celebrates the lights of downtown Tokyo.
--   - Catppuccin: A soothing pastel theme.
--   - Kanagawa: Inspired by the colors of the famous painting by Hokusai.
--   - Rose Pine: All natural pine, faux fur and a bit of soho vibes.
--   - Gruvbox Material: A modified version of Gruvbox with softer contrast.
--
-- Usage:
--   To change the theme, run `:colorscheme <name>`
--   e.g., `:colorscheme tokyonight`, `:colorscheme catppuccin`
-- ============================================================================

return {
	{
		"folke/tokyonight.nvim",
		lazy = false, -- Load immediately so it can be used for startup
		priority = 1000, -- Load before other plugins to ensure UI elements are colored correctly
		opts = {},
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {},
	},
	{
		"rebelot/kanagawa.nvim",
		priority = 1000,
		opts = {},
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		priority = 1000,
		opts = {},
	},
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
		config = function()
			-- Optional configuration for Gruvbox Material
			vim.g.gruvbox_material_background = "hard"
			vim.g.gruvbox_material_better_performance = 1
		end,
	},
}
