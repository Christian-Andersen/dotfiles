-- ============================================================================
-- NEOVIM CONFIGURATION
-- ============================================================================
-- This is the main initialization file for Neovim.
-- It contains core settings, keybindings, and plugin configuration.
-- ============================================================================

-- Set <space> as the leader key
-- The leader key is used as a prefix for custom keybindings (e.g., <leader>f for format)
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.filetype.add({
	pattern = {
		[".env.*"] = "env",
		[".env"] = "env",
	},
})

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Set global terminal scrollback to 100,000 lines
vim.opt.scrollback = 100000

-- Enable UI2: no more press Enter
require("vim._core.ui2").enable({
	enable = true,
	msg = {
		targets = "cmd",
		cmd = { height = 0.5 },
		dialog = { height = 0.5 },
		msg = { height = 0.5, timeout = 4000 },
		pager = { height = 0.5 },
	},
})

-- ============================================================================
-- [[ EDITOR OPTIONS ]]
-- ============================================================================
-- Configure core editor behavior and visual settings
-- For more information, see `:help vim.o` and `:help option-list`
-- NOTE: Most options are configured here using vim.o, which sets global options.
-- Use vim.opt for options that work with tables.
-- ============================================================================

-- Make W also write command because of accidently holding shift
vim.api.nvim_create_user_command("W", "write <args>", {
	bang = true,
	nargs = "*",
	complete = "file",
	desc = "Alias for :w",
})

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
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [q]uickfix list" })

-- Exit terminal mode with a more intuitive key combination
-- By default, you need to press <C-\><C-n> to exit terminal mode, which is hard to discover
-- This mapping allows <Esc><Esc> instead - much more intuitive
-- NOTE: This may not work in all terminal emulators or within tmux
-- If it doesn't work for you, use the default <C-\><C-n> or adjust the mapping
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Navigate between splits with Ctrl+h/j/k/l
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Go to last buffer (alternate file)
vim.keymap.set("n", "<leader>b", "<C-^>", { desc = "Go to last [b]uffer" })

-- Google AI Search
local function google_ai_search()
	local code_block = ""
	local mode = vim.api.nvim_get_mode().mode

	if mode == "v" or mode == "V" or mode == "\22" then
		vim.cmd('noau normal! "vy"')
		local selected = vim.fn.getreg("v"):match("^%s*(.-)%s*$")
		local ft = vim.bo.filetype
		if ft ~= "" then
			code_block = "```" .. ft .. "\n" .. selected .. "\n```\n"
		else
			code_block = "```\n" .. selected .. "\n```\n"
		end
	end

	vim.ui.input({
		prompt = "Google AI Prompt: ",
	}, function(input)
		if not input or input == "" then
			return
		end
		local query = code_block .. input
		local encoded = query
			:gsub("([^%w ])", function(c)
				return string.format("%%%02X", string.byte(c))
			end)
			:gsub(" ", "+")
		local url = "https://www.google.com/search?udm=50&q=" .. encoded
		vim.fn.jobstart({ "xdg-open", url }, { detach = true })
	end)
end
vim.keymap.set({ "n", "v" }, "<leader><CR>", google_ai_search, { desc = "Search Google AI with Prompt" })

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

-- Auto-enter insert mode when opening a terminal
vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
	pattern = "term://*",
	command = "startinsert",
})

-- ============================================================================
-- [[ PLUGINS (vim.pack — Neovim 0.12 built-in) ]]
-- ============================================================================

-- Build hooks via PackChanged events
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

-- Enable builtin undo tree and diff tool (Neovim 0.12+)
vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")

-- Register and load all plugins
vim.pack.add({
	-- Core
	"https://github.com/folke/snacks.nvim",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/neovim/nvim-lspconfig", -- required by mason-lspconfig
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/folke/lazydev.nvim",
	-- Completion
	"https://github.com/saghen/blink.cmp",
	-- Formatting & Linting
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/mfussenegger/nvim-lint",
	-- Debug
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/igorlfs/nvim-dap-view",
	"https://github.com/mfussenegger/nvim-dap-python",
	"https://github.com/jay-babu/mason-nvim-dap.nvim",
	-- LSP management
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mason-org/mason-lspconfig.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	-- Misc
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/folke/todo-comments.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	-- Themes
	"https://github.com/folke/tokyonight.nvim",
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	"https://github.com/rebelot/kanagawa.nvim",
	{ src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
	"https://github.com/sainnhe/gruvbox-material",
	"https://github.com/xeind/nightingale.nvim",
	"https://github.com/EdenEast/nightfox.nvim",
})

-- Snacks
require("snacks").setup({
	bigfile = { enabled = true },
	explorer = { enabled = true },
	indent = { enabled = true },
	input = { enabled = true },
	picker = {
		enabled = true,
		sources = {
			explorer = {
				auto_close = true,
			},
		},
	},
	notifier = { enabled = true },
	quickfile = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	words = { enabled = true },
	git = { enabled = true },
	gitbrowse = { enabled = true },
	lazygit = { enabled = true },
	image = { enabled = true },
	toggle = { enabled = true },
})
-- Snacks debug helpers
vim.schedule(function()
	_G.dd = function(...)
		Snacks.debug.inspect(...)
	end
	_G.bt = function()
		Snacks.debug.backtrace()
	end
	vim.print = _G.dd
end)
-- Snacks keymaps
local snacks_keys = {
	{
		"<leader><space>",
		function()
			Snacks.picker.buffers()
		end,
		desc = "Buffers [ ]",
	},
	{
		"<leader>sf",
		function()
			Snacks.picker.files()
		end,
		desc = "Search [f]iles",
	},
	{
		"<leader>sg",
		function()
			Snacks.picker.grep()
		end,
		desc = "Search by [g]rep",
	},
	{
		"<leader>:",
		function()
			Snacks.picker.command_history()
		end,
		desc = "Command history [:]",
	},
	{
		"<leader>n",
		function()
			Snacks.notifier.show_history()
		end,
		desc = "[n]otification history",
	},
	{
		"<leader>e",
		function()
			Snacks.explorer()
		end,
		desc = "File [e]xplorer",
	},
	{
		"<leader>st",
		"<cmd>TodoQuickFix<CR>",
		desc = "Search [t]odo comments",
	},
	{
		"<leader>sT",
		"<cmd>TodoQuickFix keywords=TODO,FIX,FIXME<CR>",
		desc = "Search [T]odo/Fixme",
	},
	{
		"<leader>sh",
		function()
			Snacks.picker.help()
		end,
		desc = "Search [h]elp",
	},
	{
		"<leader>sk",
		function()
			Snacks.picker.keymaps()
		end,
		desc = "Search [k]eymaps",
	},
	{
		"<leader>ss",
		function()
			Snacks.picker.pickers()
		end,
		desc = "Search [s]elect (pickers)",
	},
	{
		"<leader>sw",
		function()
			Snacks.picker.grep_word()
		end,
		desc = "Search current [w]ord",
		mode = { "n", "x" },
	},
	{
		"<leader>sd",
		function()
			Snacks.picker.diagnostics()
		end,
		desc = "Search [d]iagnostics",
	},
	{
		"<leader>sr",
		function()
			Snacks.picker.resume()
		end,
		desc = "Search [r]esume",
	},
	{
		"<leader>s.",
		function()
			Snacks.picker.recent()
		end,
		desc = "Search recent files [.]",
	},
	{
		"<leader>/",
		function()
			Snacks.picker.lines()
		end,
		desc = "Search buffer [/] lines",
	},
	{
		"<leader>s/",
		function()
			Snacks.picker.grep_buffers()
		end,
		desc = "Search open buffers [/]",
	},
	{
		"<leader>sn",
		function()
			Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
		end,
		desc = "Search [n]eovim files",
	},
	{
		"\\",
		function()
			Snacks.explorer()
		end,
		desc = "Toggle explorer [\\]",
	},
	{
		"<leader>gb",
		function()
			Snacks.git.blame_line()
		end,
		desc = "Git [b]lame line",
	},
	{
		"<leader>gB",
		function()
			Snacks.gitbrowse()
		end,
		desc = "Git [B]rowse",
	},
	{
		"<leader>gg",
		function()
			Snacks.lazygit()
		end,
		desc = "Lazy[g]it",
	},
	{
		"<leader>gl",
		function()
			Snacks.lazygit.log()
		end,
		desc = "Lazygit [l]og (CWD)",
	},
	{
		"<leader>gf",
		function()
			Snacks.lazygit.log_file()
		end,
		desc = "Lazygit current [f]ile history",
	},
	{
		"gd",
		function()
			Snacks.picker.lsp_definitions()
		end,
		desc = "Go to [d]efinition",
	},
	{
		"gD",
		function()
			Snacks.picker.lsp_declarations()
		end,
		desc = "Go to [D]eclaration",
	},
	{
		"gr",
		function()
			Snacks.picker.lsp_references()
		end,
		nowait = true,
		desc = "Go to [r]eferences",
	},
	{
		"gI",
		function()
			Snacks.picker.lsp_implementations()
		end,
		desc = "Go to [I]mplementation",
	},
	{
		"gy",
		function()
			Snacks.picker.lsp_type_definitions()
		end,
		desc = "Go to t[y]pe definition",
	},
	{
		"<leader>sl",
		function()
			Snacks.picker.lsp_symbols()
		end,
		desc = "LSP [s]ymbols",
	},
	{
		"<leader>sL",
		function()
			Snacks.picker.lsp_workspace_symbols()
		end,
		desc = "LSP workspace [S]ymbols",
	},
	{
		"<leader>th",
		function()
			Snacks.toggle.inlay_hints():toggle()
		end,
		desc = "Toggle inlay [h]ints",
	},
	{
		"<leader>ts",
		function()
			Snacks.toggle.option("spell", { name = "Spelling" }):toggle()
		end,
		desc = "Toggle [s]pelling",
	},
	{
		"<leader>tw",
		function()
			Snacks.toggle.option("wrap", { name = "Wrap" }):toggle()
		end,
		desc = "Toggle [w]rap",
	},
	{
		"<leader>tr",
		function()
			Snacks.toggle.option("relativenumber", { name = "Relative Number" }):toggle()
		end,
		desc = "Toggle [r]elative number",
	},
	{
		"<leader>td",
		function()
			Snacks.toggle.diagnostics():toggle()
		end,
		desc = "Toggle [d]iagnostics",
	},
	{
		"<leader>tl",
		function()
			Snacks.toggle.line_number():toggle()
		end,
		desc = "Toggle [l]ine number",
	},
	{
		"<leader>tc",
		function()
			Snacks.toggle
				.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
				:toggle()
		end,
		desc = "Toggle [c]onceal",
	},
	{
		"<leader>z",
		function()
			Snacks.zen()
		end,
		desc = "Toggle [z]en mode",
	},
	{
		"<leader>Z",
		function()
			Snacks.zen.zoom()
		end,
		desc = "Toggle [Z]oom",
	},
	{
		"<leader>.",
		function()
			Snacks.scratch()
		end,
		desc = "Toggle scratch buffer [.]",
	},
	{
		"<leader>S",
		function()
			Snacks.scratch.select()
		end,
		desc = "[S]elect scratch buffer",
	},
	{
		"<leader>bd",
		function()
			Snacks.bufdelete()
		end,
		desc = "[b]uffer [d]elete",
	},
	{
		"<leader>cR",
		function()
			Snacks.rename.rename_file()
		end,
		desc = "Rename file [R]",
	},
	{
		"<c-/>",
		function()
			Snacks.terminal()
		end,
		desc = "Toggle terminal [/]",
	},
	{
		"]]",
		function()
			Snacks.words.jump(vim.v.count1)
		end,
		desc = "Next reference []]",
		mode = { "n", "t" },
	},
	{
		"[[",
		function()
			Snacks.words.jump(-vim.v.count1)
		end,
		desc = "Prev reference [[[]",
		mode = { "n", "t" },
	},
}
for _, key in ipairs(snacks_keys) do
	local mode = key.mode or "n"
	vim.keymap.set(mode, key[1], key[2], { desc = key.desc, nowait = key.nowait })
end

-- Treesitter (v1.0+: no more nvim-treesitter.configs, highlight/indent are automatic)
require("nvim-treesitter").setup({})

-- Blink.cmp
require("blink.cmp").setup({
	keymap = { preset = "default" },
	appearance = { nerd_font_variant = "mono" },
	completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
	sources = {
		default = { "lsp", "path", "snippets", "lazydev" },
		providers = {
			lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
		},
	},
	fuzzy = { implementation = "lua" },
	signature = { enabled = true },
})

-- Conform (formatting)
require("conform").setup({
	notify_on_error = false,
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettierd" },
		typescript = { "prettierd" },
		javascriptreact = { "prettierd" },
		typescriptreact = { "prettierd" },
		json = { "prettierd" },
		css = { "prettierd" },
		scss = { "prettierd" },
		html = { "prettierd" },
		sh = { "shfmt" },
		bash = { "shfmt" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		sql = { "sql-formatter" },
	},
})
vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })
vim.keymap.set({ "n", "i", "x" }, "<C-s>", function()
	require("conform").format({ lsp_format = "fallback" })
	vim.cmd("w")
end, { desc = "Format and Save" })

-- Lint
require("lint").linters_by_ft = {
	javascript = { "eslint_d" },
	typescript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	sh = { "shellcheck" },
	env = { "dotenv_linter" },
}
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("lint", { clear = true }),
	callback = function()
		if vim.bo.modifiable then
			require("lint").try_lint()
		end
	end,
})

-- Gitsigns
require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end
		map("n", "]c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end, { desc = "Jump to next git [c]hange" })
		map("n", "[c", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end, { desc = "Jump to previous git [c]hange" })
		map("v", "<leader>hs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "git [s]tage hunk" })
		map("v", "<leader>hr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "git [r]eset hunk" })
		map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "git [s]tage hunk" })
		map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "git [r]eset hunk" })
		map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
		map("n", "<leader>hu", gitsigns.stage_hunk, { desc = "git [u]ndo stage hunk" })
		map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
		map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
		map("n", "<leader>hb", gitsigns.blame_line, { desc = "git [b]lame line" })
		map("n", "<leader>hd", gitsigns.diffthis, { desc = "git [d]iff against index" })
		map("n", "<leader>hD", function()
			gitsigns.diffthis("@")
		end, { desc = "git [D]iff against last commit" })
		map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "[T]oggle git show [b]lame line" })
		map("n", "<leader>tD", gitsigns.preview_hunk_inline, { desc = "[T]oggle git show [D]eleted" })
	end,
})

-- Which-key
require("which-key").setup({
	delay = 0,
	icons = {
		mappings = vim.g.have_nerd_font,
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
	spec = {
		{ "<leader>s", group = "[s]earch" },
		{ "<leader>t", group = "[t]oggle" },
		{ "<leader>d", group = "[d]ebug" },
		{ "<leader>h", group = "Git [h]unk", mode = { "n", "v" } },
		{ "<leader>g", group = "[g]it" },
		{ "<leader>f", desc = "[f]ormat" },
		{ "<leader>q", desc = "[q]uickfix" },
		{ "g", group = "[g]oto / LSP" },
		{ "gr", group = "[r]ename / Ref" },
	},
})

-- LazyDev
require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})

-- Autopairs
require("nvim-autopairs").setup({})

-- Todo Comments
vim.cmd.packadd("todo-comments.nvim")
require("todo-comments").setup({})

-- LSP Configuration
require("mason").setup({})
require("mason-lspconfig").setup({})
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end
		map("gra", vim.lsp.buf.code_action, "[g]oto code [a]ction", { "n", "x" })
		map("grD", vim.lsp.buf.declaration, "[g]oto [D]eclaration")
	end,
})
vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = vim.g.have_nerd_font and {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	} or {},
	virtual_text = { source = "if_many", spacing = 2 },
})
local servers = {
	["bashls"] = {},
	["clangd"] = {},
	["jsonls"] = {},
	["ts_ls"] = {},
	["dockerls"] = {},
	["yamlls"] = {},
	["cssls"] = {},
	["emmet_ls"] = {},
	["fish_lsp"] = {},
	["azure_pipelines_ls"] = {},
	["just"] = {},
	["rust_analyzer"] = {},
	["ruff"] = { init_options = { settings = { lineLength = 120 } } },
	["ty"] = {
		cmd = { "ty", "server" },
		filetypes = { "python" },
		root_markers = { "pyproject.toml", "uv.lock", ".git" },
		settings = { ty = { experimental = { rename = true } } },
	},
	["lua_ls"] = { settings = { Lua = { completion = { callSnippet = "Replace" } } } },
}
local lsp_to_mason = {
	rust_analyzer = "rust-analyzer",
	lua_ls = "lua-language-server",
	ts_ls = "typescript-language-server",
	jsonls = "json-lsp",
	bashls = "bash-language-server",
	dockerls = "dockerfile-language-server",
	yamlls = "yaml-language-server",
	cssls = "css-lsp",
	emmet_ls = "emmet-ls",
	fish_lsp = "fish-lsp",
	azure_pipelines_ls = "azure-pipelines-language-server",
	just = "just-lsp",
}
local ensure_installed = {}
for name, _ in pairs(servers) do
	table.insert(ensure_installed, lsp_to_mason[name] or name)
end
vim.list_extend(
	ensure_installed,
	{ "stylua", "shfmt", "prettierd", "eslint_d", "clang-format", "sql-formatter", "dotenv-linter", "shellcheck" }
)
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
for name, config in pairs(servers) do
	config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
	vim.lsp.config[name] = config
	vim.lsp.enable(name)
end

-- Debug (DAP)
require("mason-nvim-dap").setup({ ensure_installed = { "python" }, handlers = {}, automatic_installation = false })
require("dap-view").setup()
local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
require("dap-python").setup(mason_path)
local dap = require("dap")
local dap_view = require("dap-view")
vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Set Conditional Breakpoint" })
vim.keymap.set("n", "<leader>dv", dap_view.toggle, { desc = "Debug: Toggle View" })
vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "Debug: Terminate/Exit" })
dap.listeners.after.event_initialized["dap_view_config"] = function()
	dap_view.open()
end
dap.listeners.after.event_initialized["dap_exception_config"] = function()
	dap.set_exception_breakpoints({ "uncaught" })
end
vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "", linehl = "", numhl = "" })

-- Theme
local theme = vim.env.NVIM_THEME or "wildcharm"
if not pcall(vim.cmd.colorscheme, theme) then
	vim.notify("Failed to load theme: " .. theme .. ". Falling back to wildcharm.", vim.log.levels.WARN)
end

-- ============================================================================
-- The line below is a vim modeline that sets editor options for this specific file
-- It tells Vim to use 2-space indentation and expand tabs to spaces
-- See `:help modeline` for more information about modelines
vim.opt.tabstop = 2 -- Tab width for display
vim.opt.softtabstop = 2 -- Spaces for soft tabs
vim.opt.shiftwidth = 2 -- Spaces for auto-indentation
vim.opt.expandtab = true -- Expand tabs to spaces
-- vim: ts=2 sts=2 sw=2 et
