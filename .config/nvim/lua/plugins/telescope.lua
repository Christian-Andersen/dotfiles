-- ============================================================================
-- TELESCOPE FUZZY FINDER
-- ============================================================================
-- telescope.nvim: Highly extensible fuzzy finder for Neovim
--
-- Features:
--   - Find files quickly with fuzzy matching
--   - Search text across entire project (live grep)
--   - Find references, definitions, implementations (with LSP)
--   - Search keymaps, commands, help tags
--   - Browse open buffers
--   - Show diagnostics
--   - Beautiful UI with preview
--   - Extensible with custom pickers
--
-- Keybindings:
--   <leader>sh : Search [H]elp tags
--   <leader>sk : Search [K]eymaps
--   <leader>sf : Search [F]iles
--   <leader>ss : Search [S]elect Telescope (show all built-in pickers)
--   <leader>sw : Search current [W]ord
--   <leader>sg : Search by [G]rep (live grep)
--   <leader>sd : Search [D]iagnostics
--   <leader>sr : Search [R]esume (previous search)
--   <leader>s. : Search recent files
--   <leader><leader> : Find existing buffers
--   <leader>/ : Fuzzily search in current buffer
--   <leader>s/ : Search in open files
--   <leader>sn : Search [N]eovim config files
--
-- Repo: https://github.com/nvim-telescope/telescope.nvim
-- ============================================================================

return {
	"nvim-telescope/telescope.nvim",
	-- Load on VimEnter (before opening any file)
	event = "VimEnter",

	-- Dependencies
	dependencies = {
		-- Plenary: Utility library used by telescope
		"nvim-lua/plenary.nvim",
		-- Optional: fzf native extension for better performance
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			-- Requires compilation with make
			build = "make",
			-- Only build if make is available
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		-- UI select extension: use telescope for vim.ui.select()
		{ "nvim-telescope/telescope-ui-select.nvim" },
		-- Web dev icons for file type icons
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	},

	-- Configuration function
	config = function()
		-- Configure telescope
		require("telescope").setup({
			extensions = {
				-- UI select extension: shows telescope interface for vim.ui.select()
				-- Used for plugin configuration and other UI selections
				["ui-select"] = {
					require("telescope.themes").get_dropdown(), -- Use dropdown theme
				},
			},
		})

		-- Safely load extensions (if not available, just skip them)
		-- This prevents errors if a dependency isn't installed
		pcall(require("telescope").load_extension, "fzf") -- Native fzf extension
		pcall(require("telescope").load_extension, "ui-select") -- UI select extension

		-- Load telescope builtin functions
		local builtin = require("telescope.builtin")

		-- Set up keybindings for various telescope pickers
		-- Each keymap opens a different fuzzy finder view

		-- Search help tags - Find Neovim help topics
		vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
		-- Search keymaps - Find all your configured keybindings
		vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
		-- Search files - Find files in project using fuzzy matching
		vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
		-- Search select - Show available telescope pickers (meta search)
		vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
		-- Search word - Find all occurrences of the word under cursor
		vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
		-- Search grep - Live grep: search text patterns in files
		vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
		-- Search diagnostics - Find all errors/warnings/info in project
		vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
		-- Search resume - Resume the last telescope search
		vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
		-- Search oldfiles - Find recently opened files
		vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
		-- Find buffers - Switch between open buffers
		vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

		-- Search within current buffer - Fuzzy search text in the active buffer
		-- Useful for navigating large files
		vim.keymap.set("n", "<leader>/", function()
			builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10, -- Make the background slightly transparent
				previewer = false, -- Don't show file preview in buffer search
			}))
		end, { desc = "[/] Fuzzily search in current buffer" })

		-- Search and grep in open files - Live grep only in currently open files
		vim.keymap.set("n", "<leader>s/", function()
			builtin.live_grep({
				grep_open_files = true,
				prompt_title = "Live Grep in Open Files",
			})
		end, { desc = "[S]earch [/] in Open Files" })

		-- Search Neovim config files - Find files in Neovim config directory
		-- Useful for quickly navigating and editing your config
		vim.keymap.set("n", "<leader>sn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") }) -- Search in ~/.config/nvim/
		end, { desc = "[S]earch [N]eovim files" })
	end,
}
