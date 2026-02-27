-- ============================================================================
-- HARPOON 2
-- ============================================================================
-- harpoon: Navigate between marked files with ease
--
-- Features:
--   - Mark files for quick navigation
--   - Toggle a menu to see and edit marked files
--   - Fast switching between marks using keybindings
--   - Persistent marks across sessions
--
-- Keybindings:
--   <leader>a : [A]dd current file to Harpoon list
--   <C-e>     : Toggle Harpoon quick menu ([E]dit list)
--   <C-1..0>  : Select Harpoon file 1..9
--
-- Repo: https://github.com/ThePrimeagen/harpoon/tree/harpoon2
-- ============================================================================

return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()
		-- Add current file to harpoon list
		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end, { desc = "Harpoon [A]dd file" })
		-- Toggle harpoon menu
		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon [E]dit menu" })
		-- Navigate to specific harpoon files (1-9)
		for i = 1, 9 do
			vim.keymap.set("n", "<C-" .. i .. ">", function()
				harpoon:list():select(i)
			end, { desc = "Harpoon Select " .. i })
			vim.keymap.set("n", "<leader>" .. i, function()
				harpoon:list():select(i)
			end, { desc = "Harpoon Select " .. i .. " (Leader)" })
		end
	end,
}
