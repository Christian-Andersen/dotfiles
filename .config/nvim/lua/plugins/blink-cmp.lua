-- ============================================================================
-- BLINK.CMP COMPLETION ENGINE
-- ============================================================================
-- blink.cmp: A fast and feature-rich completion menu for Neovim
--
-- Features:
--   - Fast fuzzy completion with lua implementation (no native dependencies)
--   - Integrates with LSP, snippets, and custom sources
--   - Customizable completion menu appearance
--   - Supports signature help and inline documentation
--   - Works with LuaSnip for snippet expansion
--   - Lightweight and responsive
--
-- Repo: https://github.com/saghen/blink.cmp
-- ============================================================================

return {
	"saghen/blink.cmp",
	-- Load when entering Neovim (before any file is opened)
	-- This ensures completion is ready immediately
	event = "VimEnter",
	-- Track the latest version (1.*) of blink.cmp
	-- The version constraint ensures compatibility
	version = "1.*",

	-- Dependencies that blink.cmp needs to function
	dependencies = {
		-- LuaSnip: Snippet engine for expanding code templates
		{
			"L3MON4D3/LuaSnip",
			version = "2.*",
			-- Build command to compile regex support for better snippet matching
			-- Only runs if the system has make available (skip on Windows)
			build = (function()
				if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
					return
				end
				return "make install_jsregexp"
			end)(),
			dependencies = {},
			opts = {},
		},
		-- LazyDev: Provides Neovim API documentation for completion in Lua files
		"folke/lazydev.nvim",
	},

	-- Configuration options for blink.cmp
	opts = {
		-- Keymap configuration: use default keybindings
		-- Tab/Shift-Tab to navigate, Enter to confirm, Esc to cancel
		keymap = {
			preset = "default",
		},
		-- UI appearance settings
		appearance = {
			-- Use monospace variant of Nerd Font icons for better alignment
			nerd_font_variant = "mono",
		},
		-- Completion behavior settings
		completion = {
			-- Documentation window (shows parameter info, type details, etc.)
			-- auto_show = false: Only show when explicitly requested or needed
			-- auto_show_delay_ms = 500: Delay before showing documentation
			documentation = { auto_show = false, auto_show_delay_ms = 500 },
		},
		-- Define which sources provide completion items
		sources = {
			-- Default sources to use: LSP, file paths, snippets, and lazydev
			default = { "lsp", "path", "snippets", "lazydev" },
			-- Provider-specific configuration
			providers = {
				-- LazyDev provider: gives Neovim API completion a higher score
				-- score_offset = 100 means results from lazydev rank higher
				lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
			},
		},
		-- Snippet engine: Use LuaSnip to expand snippets
		-- This tells blink.cmp which snippet engine to use
		snippets = { preset = "luasnip" },
		-- Fuzzy matching: Use pure Lua implementation (no native deps needed)
		fuzzy = { implementation = "lua" },
		-- Function signature help: Show parameter info while typing function calls
		signature = { enabled = true },
	},
}
