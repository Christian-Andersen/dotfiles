-- ============================================================================
-- TODO COMMENTS PLUGIN
-- ============================================================================
-- todo-comments.nvim: Highlights and searches for todo/fixme/hack comments
--
-- Features:
--   - Highlights TODO, FIXME, HACK, WARN, NOTE, PERF, TEST comments
--   - Search all todo comments in project with :TodoTelescope
--   - Shows counts of todo items
--   - Customizable comment keywords and colors
--   - Works with all file types
--   - Helps find incomplete work in large codebases
--
-- Default keywords (customizable):
--   - TODO: Task to be done
--   - FIXME: Bug or issue to fix
--   - HACK: Workaround or temporary solution
--   - WARN: Warning message
--   - NOTE: Important note
--   - PERF: Performance improvement idea
--   - TEST: Test to be written
--
-- Repo: https://github.com/folke/todo-comments.nvim
-- ============================================================================

return {
	"folke/todo-comments.nvim",
	-- Load on VimEnter (before opening any file)
	event = "VimEnter",
	-- Required dependency: plenary for utility functions
	dependencies = { "nvim-lua/plenary.nvim" },
	-- Configuration options
	opts = {
		-- Don't show signs (symbols) in the gutter
		-- The comments will still be highlighted, just without gutter markers
		signs = false,
	},
}
