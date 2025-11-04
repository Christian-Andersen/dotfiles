-- ============================================================================
-- LAZYDEV PLUGIN
-- ============================================================================
-- lazydev.nvim: Provides LSP support for Neovim API documentation in Lua
--
-- Features:
--   - IntelliSense for Neovim API functions and modules
--   - Type hints for vim.* functions
--   - Access to accurate Neovim documentation through the LSP
--   - Autocompletion for Lua scripting and configuration
--   - Speeds up Lua development and Neovim configuration editing
--
-- Why it's useful:
--   - When writing Neovim configuration (init.lua and plugin files)
--   - When developing Lua plugins for Neovim
--   - Eliminates the need to constantly check the :help documentation
--   - Provides accurate type information and signatures
--
-- Repo: https://github.com/folke/lazydev.nvim
-- ============================================================================

return {
	"folke/lazydev.nvim",
	-- Load only for Lua files (.lua extension)
	-- This keeps startup time fast by not loading in other file types
	ft = "lua",
	-- Configuration options
	opts = {
		-- Additional libraries to load for Neovim API completion
		-- Libraries provide type definitions and documentation
		library = {
			-- Load the Luv (Libuv bindings) library for vim.uv completions
			-- Luv provides async I/O, filesystem, and system operations
			-- This allows completions for vim.uv.* functions
			{
				path = "${3rd}/luv/library", -- Path to the Luv library stubs
				words = { "vim%.uv" }, -- Which words should trigger this library
			},
		},
	},
}
