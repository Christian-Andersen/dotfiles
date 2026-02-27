-- ============================================================================
-- PLUGIN LOADER
-- ============================================================================
-- This file loads and returns all plugin specifications from the plugins/ directory
-- Each file in plugins/ contains a Lua table describing how lazy.nvim should load that plugin
-- Plugins are loaded in the order they appear here, though lazy.nvim will optimize loading
-- based on events, file types, and keybindings specified in each plugin file
-- ============================================================================

-- Return a table containing all plugin specifications
-- lazy.nvim will process each table and handle installation, loading, and configuration
return {
	-- ============================================================================
	-- PLUGIN SPECIFICATIONS
	-- ============================================================================
	-- Each require() loads a plugin specification file from the plugins/ directory
	-- ============================================================================

	-- Autopairs plugin: automatically close brackets, parentheses, and quotes
	require("plugins.autopairs"),
	-- Blink completion menu: fast and feature-rich completion framework
	require("plugins.blink-cmp"),
	-- Conform: code formatter supporting multiple languages and formatters
	require("plugins.conform"),
	-- Git signs: shows git changes (additions, modifications, deletions) in the gutter
	require("plugins.gitsigns"),
	-- Guess indent: automatically detects indentation settings (tabs/spaces, width)
	require("plugins.guess-indent"),
	-- Indent blankline: displays indentation guides as vertical lines
	require("plugins.indent-blankline"),
	-- LazyDev: provides LSP support for Neovim API documentation in Lua files
	require("plugins.lazydev"),
	-- Lint: runs linters on files to check for code style and potential issues
	require("plugins.lint"),
	-- LSP Config: configures language servers for IntelliSense and diagnostics
	require("plugins.lspconfig"),
	-- Mini: collection of minimal, independent, and composable plugins (ai, surround, statusline)
	require("plugins.mini"),
	-- Neo-tree: file tree browser for navigating the project structure
	require("plugins.neo-tree"),
	-- Harpoon: navigate between marked files with ease
	require("plugins.harpoon"),
	-- Telescope: fuzzy finder for files, commands, text search, and more
	require("plugins.telescope"),
	-- Todo comments: highlights and searches todo/fixme/hack/warn comments
	require("plugins.todo-comments"),
	-- Treesitter: provides better syntax highlighting and code navigation
	require("plugins.treesitter"),
	-- Which-key: shows available keybindings when you start typing a key sequence
	require("plugins.which-key"),
	-- Debug: Debug Adapter Protocol (DAP) setup
	require("plugins.debug"),
	-- Themes: Collection of popular color schemes
	require("plugins.themes"),
	-- Grug-far: Project-wide search and replace
	require("plugins.grug-far"),
}
