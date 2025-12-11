-- ============================================================================
-- NEOVIM CONFIGURATION
-- ============================================================================
-- This is the main initialization file for Neovim.
-- It contains core settings, keybindings, and configuration options.
-- Plugin configurations are managed separately in lua/plugins/
-- ============================================================================

-- Set <space> as the leader key
-- The leader key is used as a prefix for custom keybindings (e.g., <leader>f for format)
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- ============================================================================
-- [[ EDITOR OPTIONS ]]
-- ============================================================================
-- Configure core editor behavior and visual settings
-- For more information, see `:help vim.o` and `:help option-list`
-- NOTE: Most options are configured here using vim.o, which sets global options.
-- Use vim.opt for options that work with tables.
-- ============================================================================

-- Make W also write command because of accidently holding shift
vim.api.nvim_create_user_command("W", "w", { desc = 'Alias for :w' })

-- Make line numbers default (shows absolute line numbers on the left)
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.o.relativenumber = true

-- Enable mouse mode for all vim modes ('a')
-- This allows you to interact with the editor using a mouse:
-- - Click to position cursor
-- - Scroll to navigate
-- - Drag to select
-- - Resize split windows
vim.o.mouse = "a"

-- Don't show the mode indicator (e.g., "-- INSERT --")
-- The current mode is already shown in the status line by the mini.statusline plugin
vim.o.showmode = false

-- Sync clipboard between OS and Neovim
-- This allows seamless copy/paste between Neovim and your system clipboard
-- - yanked text is copied to system clipboard
-- - system clipboard content can be pasted into Neovim
-- Schedule this after 'UiEnter' to avoid increasing startup time
-- Remove this option if you want your OS clipboard to remain independent
-- See `:help 'clipboard'`
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- Enable break indent
-- When a line is visually broken/wrapped, the continuation lines are indented
-- to align with the first line
vim.o.breakindent = true

-- Save undo history to a file
-- This persists the undo history even after closing and reopening a file
-- Allows you to undo changes from previous editing sessions
vim.o.undofile = true

-- Case-insensitive searching by default
-- However, if the search pattern contains uppercase letters, the search becomes case-sensitive
-- This is called "smart case" - it provides the best of both worlds
-- Examples:
--   /foo      -> finds 'foo', 'Foo', 'FOO' (case-insensitive)
--   /Foo      -> finds only 'Foo' (case-sensitive)
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep the sign column always visible on the left
-- The sign column is used by various plugins to display:
-- - LSP diagnostics (errors, warnings, info)
-- - Git changes (added, modified, deleted lines)
-- - Breakpoints (for debugging)
-- Setting to 'yes' reserves space even when there are no signs
vim.o.signcolumn = "yes"

-- Decrease update time (in milliseconds)
-- Affects how quickly plugins respond to text changes
-- Lower value = more responsive but slightly higher CPU usage
-- Used by features like:
-- - Vim CursorHold events (document highlighting)
-- - Linting and diagnostic updates
vim.o.updatetime = 250

-- Decrease the timeout for mapped key sequences (in milliseconds)
-- When you press a key that starts a mapping, Neovim waits this long for more keys
-- Lower value means less wait time but faster perceived response
-- Relevant for:
-- - Leader key sequences (e.g., <leader>f)
-- - Multi-key commands
vim.o.timeoutlen = 300

-- Configure how new split windows should be opened
-- splitright: new vertical splits appear on the right (instead of left)
-- splitbelow: new horizontal splits appear below (instead of above)
vim.o.splitright = true
vim.o.splitbelow = true

-- Display whitespace characters as visible symbols
-- This helps identify trailing whitespace, tabs, and non-breaking spaces
-- See `:help 'list'` and `:help 'listchars'` for more details
--
-- Note: listchars is set using `vim.opt` instead of `vim.o` because it's a table option
-- vim.opt provides a convenient interface for manipulating table-based options
-- See `:help lua-options` and `:help lua-options-guide` for more info
vim.o.list = true
-- Configure which whitespace characters to show and their symbols:
--   tab = '» '    : displays tabs as '» ' (double-width for clarity)
--   trail = '·'   : shows trailing whitespace as middle dots
--   nbsp = '␣'    : indicates non-breaking spaces
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live as you type
-- When using the substitute command (e.g., :%s/old/new/), shows a preview in a split window
-- Allows you to see the changes before confirming with Enter
vim.o.inccommand = "split"

-- Highlight the entire line where the cursor is located
-- Makes it easier to see where you are in the file at a glance
vim.o.cursorline = true

-- Minimal number of screen lines to keep visible above and below the cursor
-- When scrolling, ensures there's always context around the cursor
-- Value of 10 means at least 10 lines before and after the cursor are visible
vim.o.scrolloff = 10

-- Prompt for confirmation on operations that would fail due to unsaved changes
-- Instead of just failing with an error, shows a dialog:
--   "Save changes to ...? [Y]es [N]o [C]ancel"
-- Applies to commands like `:q` (quit), `:e` (edit), `:wq` (write and quit)
-- This prevents accidental loss of work
-- See `:help 'confirm'`
vim.o.confirm = true

-- ============================================================================
-- [[ KEYBINDINGS ]]
-- ============================================================================
-- Define custom key mappings for common operations
-- See `:help vim.keymap.set()` for more details on the mapping API
-- ============================================================================

-- Clear search highlights when pressing <Esc> in normal mode
-- When you search with `/pattern`, Neovim highlights all matches
-- This binding clears those highlights for a cleaner view
-- See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Open diagnostic quickfix list
-- <leader>q : displays all diagnostics (errors, warnings, info) in a quickfix window
-- Useful for reviewing all issues in the buffer at once
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode with a more intuitive key combination
-- By default, you need to press <C-\><C-n> to exit terminal mode, which is hard to discover
-- This mapping allows <Esc><Esc> instead - much more intuitive
-- NOTE: This may not work in all terminal emulators or within tmux
-- If it doesn't work for you, use the default <C-\><C-n> or adjust the mapping
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Window/Split navigation keybindings
-- Use Ctrl+hjkl to easily move between split windows
-- This is more intuitive than the default Ctrl+w,hjkl
-- See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- ============================================================================
-- [[ AUTOCOMMANDS ]]
-- ============================================================================
-- Automatically run code when specific events occur
-- See `:help lua-guide-autocommands` for more details
-- Autocommands are organized into augroups to prevent duplicates
-- ============================================================================

-- Highlight the text that was just yanked (copied)
-- When you copy text using `y` (e.g., `yap` to yank a paragraph), the copied region
-- is temporarily highlighted, providing visual feedback that the copy was successful
-- Try it with `yap` in normal mode to select and copy a paragraph
-- See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- ============================================================================
-- [[ PLUGIN MANAGER: lazy.nvim ]]
-- ============================================================================
-- Install and configure lazy.nvim, the plugin manager for this configuration
-- lazy.nvim provides:
-- - Lazy loading of plugins (load only when needed)
-- - Automatic plugin installation and updates
-- - Fast startup times
-- For more info, see `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim
-- ============================================================================

-- Build the path to lazy.nvim in the data directory
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Install lazy.nvim if not already installed
if not vim.uv.fs_stat(lazypath) then
	-- Clone lazy.nvim from GitHub
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	-- Use git clone with blob:none filter for faster cloning
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

-- Add lazy.nvim to the runtime path so Neovim can find it
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- ============================================================================
-- [[ INITIALIZE PLUGINS ]]
-- ============================================================================
-- Load and configure all plugins from lua/plugins/
-- Each file in lua/plugins/ returns a plugin specification that lazy.nvim uses
--
-- USEFUL COMMANDS:
--   :Lazy           - Open the lazy.nvim UI to manage plugins
--   :Lazy update    - Update all plugins to their latest versions
--   :Lazy check     - Check for plugin updates without installing
--   :Lazy log       - View recent plugin updates
--   ?               - Show help when the Lazy UI is open
--
-- The second argument to setup() contains configuration for lazy.nvim itself
require("lazy").setup(require("plugins"), {
	ui = {
		-- Configure icons for the lazy.nvim UI
		-- If you have a Nerd Font installed, use empty table {} to use default Nerd Font icons
		-- Otherwise, use Unicode emoji icons for better visual feedback in the UI
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘", -- Icon for commands
			config = "🛠", -- Icon for configuration
			event = "📅", -- Icon for events that trigger lazy loading
			ft = "📂", -- Icon for filetype-based loading
			init = "⚙", -- Icon for init hooks
			keys = "🗝", -- Icon for key mappings
			plugin = "🔌", -- Icon for plugins
			runtime = "💻", -- Icon for runtime code
			require = "🌙", -- Icon for require dependencies
			source = "📄", -- Icon for source files
			start = "🚀", -- Icon for plugins that start immediately
			task = "📌", -- Icon for tasks
			lazy = "💤 ", -- Icon for lazy loading indicator
		},
	},
})

-- ============================================================================
-- [[ MODELINE ]]
-- ============================================================================
-- The line below is a vim modeline that sets editor options for this specific file
-- It tells Vim to use 2-space indentation and expand tabs to spaces
-- See `:help modeline` for more information about modelines
vim.opt.tabstop = 2 -- Tab width for display
vim.opt.softtabstop = 2 -- Spaces for soft tabs
vim.opt.shiftwidth = 2 -- Spaces for auto-indentation
vim.opt.expandtab = true -- Expand tabs to spaces
-- vim: ts=2 sts=2 sw=2 et
