-- ============================================================================
-- TREESITTER SYNTAX HIGHLIGHTING
-- ============================================================================
-- nvim-treesitter: Advanced syntax highlighting using Tree-sitter parser
--
-- Features:
--   - Better syntax highlighting than regex-based highlighting
--   - Supports 100+ languages with high accuracy
--   - Smart indentation based on parse tree
--   - Code navigation and text objects
--   - Incremental parsing for fast updates
--   - Auto-install language parsers
--
-- How it works:
--   - Tree-sitter parses files into an Abstract Syntax Tree (AST)
--   - Syntax is then applied based on the parsed structure, not regex patterns
--   - Results in more accurate and consistent highlighting
--
-- Configuration:
--   - ensure_installed: Languages to automatically download and install
--   - auto_install: Automatically install parsers for new file types
--   - highlight: Enable syntax highlighting
--   - indent: Enable smart auto-indentation
--
-- Repo: https://github.com/nvim-treesitter/nvim-treesitter
-- ============================================================================

return {
	"nvim-treesitter/nvim-treesitter",
	-- Build treesitter parsers after updating
	-- :TSUpdate is a command provided by this plugin
	build = ":TSUpdate",
	-- Use 'nvim-treesitter.configs' as the main module
	main = "nvim-treesitter.configs",
	opts = {
		-- List of languages whose parsers to ensure are installed
		-- These parsers will be auto-downloaded if missing
		ensure_installed = {
			"bash", -- Shell scripting
			"c", -- C programming
			"diff", -- Diff format (for patches)
			"html", -- HTML markup
			"json", -- JSON data format
			"lua", -- Lua (for Neovim config)
			"luadoc", -- Lua documentation comments
			"markdown", -- Markdown text formatting
			"markdown_inline", -- Inline markdown formatting
			"query", -- Tree-sitter query language
			"sql", -- SQL database queries
			"vim", -- Vim scripting
			"vimdoc", -- Vim documentation format
			"python", -- Python programming
			"javascript", -- JavaScript programming
			"typescript", -- TypeScript programming
		},
		-- Auto-install parsers when opening a file of unknown type
		-- Automatically fetches and installs the parser for that language
		auto_install = true,
		-- Enable syntax highlighting
		highlight = {
			-- Enable treesitter-based highlighting
			enable = true,
			-- Use additional Vim regex highlighting for specific languages
			-- Ruby has better regex highlighting, so disable treesitter for it
			additional_vim_regex_highlighting = { "ruby" },
		},
		-- Enable smart auto-indentation based on parse tree
		indent = {
			enable = true,
			-- Disable indentation for ruby (use default Vim indentation instead)
			disable = { "ruby" },
		},
	},
}
