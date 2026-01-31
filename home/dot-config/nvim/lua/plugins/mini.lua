-- ============================================================================
-- MINI.NVIM PLUGIN COLLECTION
-- ============================================================================
-- mini.nvim: Collection of minimal, independent, and composable Lua modules
--
-- Currently enabled modules:
--   - mini.ai: Better text objects (around/inside for any bracket/quote)
--   - mini.surround: Powerful surround operations (change, add, delete)
--   - mini.statusline: Lightweight status line (shows mode, location, etc.)
--
-- Other available mini modules (not currently enabled):
--   - mini.align, mini.bufremove, mini.comment, mini.completion, mini.cursorword
--   - mini.diff, mini.extra, mini.fuzzy, mini.indentscope, mini.jump
--   - mini.map, mini.misc, mini.move, mini.operators, mini.pairs, mini.pick
--   - mini.splitjoin, mini.starter, mini.tricky, mini.visits
--
-- Each module is extremely lightweight and can be used independently
--
-- Repo: https://github.com/echasnovski/mini.nvim
-- ============================================================================

return {
	"echasnovski/mini.nvim",
	config = function()
		-- ===== MINI.AI: Extended text objects =====
		-- Better text objects for working with brackets, quotes, and more
		-- Adds extended motions like:
		--   da( = delete around parentheses
		--   ci{ = change inside braces
		--   va[  = select around square brackets
		require("mini.ai").setup({
			-- Maximum number of lines to scan for matching brackets
			-- Lower = faster but may miss matches in very large blocks
			n_lines = 500,
		})

		-- ===== MINI.SURROUND: Surroundings manipulation =====
		-- Add, delete, and change surroundings (brackets, quotes, tags, etc.)
		-- Works with custom keybindings and text objects
		-- Examples:
		--   sa<motion><bracket> : Surround motion with bracket
		--   sd<bracket> : Delete surrounding bracket
		--   sr<bracket><new> : Replace surrounding bracket
		require("mini.surround").setup()

		-- ===== MINI.STATUSLINE: Custom status line =====
		-- Lightweight status line that shows:
		--   - Current mode (NORMAL, INSERT, VISUAL, etc.)
		--   - File name and modification status
		--   - Current line and column position
		--   - Current search count (e.g., "5/10")
		local statusline = require("mini.statusline")
		statusline.setup({
			-- Use Nerd Font icons if available, otherwise use text
			use_icons = vim.g.have_nerd_font,
		})

		-- Customize the location section to show "line:column" format
		-- This function is called to generate the location display in the status line
		---@diagnostic disable-next-line: duplicate-set-field
		statusline.section_location = function()
			-- Return the line number (%2l = 2-character left-aligned line number)
			-- And column number (%-2v = 2-character right-aligned column number)
			return "%2l:%-2v"
		end
	end,
}
