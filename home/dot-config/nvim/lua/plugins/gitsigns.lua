-- ============================================================================
-- GITSIGNS - GIT INTEGRATION
-- ============================================================================
-- gitsigns.nvim: Shows git changes in the gutter and provides git operations
--
-- Features:
--   - Visual indicators for added, modified, and deleted lines
--   - Jump to next/previous change with ]c and [c
--   - Stage/reset hunks (partial commits)
--   - Blame information (who wrote this line and when)
--   - Diff viewing within Neovim
--   - Word-level diff highlighting
--
-- Keybindings:
--   ]c          : Jump to next git change
--   [c          : Jump to previous git change
--   <leader>hs  : Stage hunk (works in normal and visual mode)
--   <leader>hr  : Reset hunk (works in normal and visual mode)
--   <leader>hS  : Stage entire buffer
--   <leader>hu  : Undo stage hunk
--   <leader>hR  : Reset entire buffer
--   <leader>hp  : Preview hunk
--   <leader>hb  : Show git blame for current line
--   <leader>hd  : Show diff against index
--   <leader>hD  : Show diff against last commit
--   <leader>tb  : Toggle blame info on current line
--   <leader>tD  : Toggle inline diff display
--
-- Repo: https://github.com/lewis6991/gitsigns.nvim
-- ============================================================================

return {
	"lewis6991/gitsigns.nvim",

	-- Configure gitsigns behavior and keybindings
	opts = {
		-- Define the signs (symbols) displayed in the gutter
		-- These show what type of change was made at each line
		signs = {
			add = { text = "+" }, -- Added lines
			change = { text = "~" }, -- Modified lines
			delete = { text = "_" }, -- Deleted lines (but can be seen in diff)
			topdelete = { text = "‾" }, -- Deleted lines at the top of a file
			changedelete = { text = "~" }, -- Lines that are changed and deleted
		},

		-- on_attach: Called when gitsigns attaches to a buffer
		-- Sets up buffer-local keybindings for git operations
		on_attach = function(bufnr)
			-- Load the gitsigns module for this buffer
			local gitsigns = require("gitsigns")

			-- Helper function to set keybindings scoped to this buffer
			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr -- Bind to this buffer only
				vim.keymap.set(mode, l, r, opts)
			end

			-- ===== NAVIGATION: Jump between git changes =====
			-- Jump to next git change (next hunk)
			map("n", "]c", function()
				-- In diff mode, use vim's built-in diff navigation
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					-- Otherwise, use gitsigns hunk navigation
					gitsigns.nav_hunk("next")
				end
			end, { desc = "Jump to next git [c]hange" })

			-- Jump to previous git change (previous hunk)
			map("n", "[c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end, { desc = "Jump to previous git [c]hange" })

			-- ===== ACTIONS: Modify staging and view diffs =====
			-- Visual mode actions (for selecting ranges of hunks)
			map("v", "<leader>hs", function()
				-- Stage the selected lines (visual selection)
				gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "git [s]tage hunk" })
			map("v", "<leader>hr", function()
				-- Reset (discard) the selected lines
				gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "git [r]eset hunk" })

			-- Normal mode actions
			map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "git [s]tage hunk" })
			map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "git [r]eset hunk" })
			-- Stage the entire buffer
			map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
			-- Undo the last stage operation
			map("n", "<leader>hu", gitsigns.stage_hunk, { desc = "git [u]ndo stage hunk" })
			-- Reset (discard all changes in) the entire buffer
			map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
			-- Preview what a hunk looks like (shows additions/deletions)
			map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
			-- Show git blame information for the current line
			-- Displays author, date, and commit hash
			map("n", "<leader>hb", gitsigns.blame_line, { desc = "git [b]lame line" })
			-- Show a diff of the current hunk against the index (staged changes)
			map("n", "<leader>hd", gitsigns.diffthis, { desc = "git [d]iff against index" })
			-- Show a diff against the last commit (@) to see all uncommitted changes
			map("n", "<leader>hD", function()
				gitsigns.diffthis("@")
			end, { desc = "git [D]iff against last commit" })

			-- ===== TOGGLES: Show/hide git information =====
			-- Toggle the display of blame information for the current line
			-- Useful for checking who wrote code and when
			map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "[T]oggle git show [b]lame line" })
			-- Toggle inline display of deleted lines
			-- Shows what was deleted (useful for reviewing changes)
			map("n", "<leader>tD", gitsigns.preview_hunk_inline, { desc = "[T]oggle git show [D]eleted" })
		end,
	},
}
