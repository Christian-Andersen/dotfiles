-- ============================================================================
-- WHICH-KEY PLUGIN
-- ============================================================================
-- which-key.nvim: Shows available keybindings when you start typing a key sequence
--
-- Features:
--   - Displays available keybindings in a popup menu
--   - Groups keybindings by prefix (e.g., all <leader>s commands together)
--   - Shows command descriptions alongside keys
--   - Helps discover keybindings without memorizing them
--   - Customizable appearance and layout
--   - Shows key icons if using Nerd Font
--
-- Usage:
--   - Type <leader> and wait a moment (or immediately press to toggle)
--   - See all available <leader>* keybindings
--   - Type additional keys to filter or select an action
--
-- Repo: https://github.com/folke/which-key.nvim
-- ============================================================================

return {
	"folke/which-key.nvim",
	-- Load on VimEnter (before opening any file)
	event = "VimEnter",
	-- Configuration options
	opts = {
		-- Delay before showing the which-key popup (in milliseconds)
		-- delay = 0 means show immediately when you press leader key
		-- Higher values mean longer wait (e.g., 1000 = 1 second)
		delay = 0,
		-- Icon configuration
		icons = {
			-- Show icons for mappings if true
			mappings = vim.g.have_nerd_font,
			-- Define custom symbols for special keys (if not using Nerd Font)
			keys = vim.g.have_nerd_font and {} or {
				Up = "<Up> ",
				Down = "<Down> ",
				Left = "<Left> ",
				Right = "<Right> ",
				C = "<C-…> ",
				M = "<M-…> ",
				D = "<D-…> ",
				S = "<S-…> ",
				CR = "<CR> ",
				Esc = "<Esc> ",
				ScrollWheelDown = "<ScrollWheelDown> ",
				ScrollWheelUp = "<ScrollWheelUp> ",
				NL = "<NL> ",
				BS = "<BS> ",
				Space = "<Space> ",
				Tab = "<Tab> ",
				F1 = "<F1>",
				F2 = "<F2>",
				F3 = "<F3>",
				F4 = "<F4>",
				F5 = "<F5>",
				F6 = "<F6>",
				F7 = "<F7>",
				F8 = "<F8>",
				F9 = "<F9>",
				F10 = "<F10>",
				F11 = "<F11>",
				F12 = "<F12>",
			},
		},
		-- Define key group labels for better organization
		-- This groups related commands under descriptive headings
		spec = {
			-- Group all <leader>a commands under the [A]dd category (Harpoon)
			{ "<leader>a", group = "Harpoon [A]dd" },
			-- Group all <leader>s commands under the [S]earch category
			{ "<leader>s", group = "[S]earch" },
			-- Group all <leader>t commands under the [T]oggle category
			{ "<leader>t", group = "[T]oggle" },
			-- Group all <leader>d commands under the [D]ebug category
			{ "<leader>d", group = "[D]ebug" },
			-- Group all <leader>h commands under the Git [H]unk category (works in normal and visual modes)
			{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
		},
	},
}
