-- ============================================================================
-- INDENT-BLANKLINE PLUGIN
-- ============================================================================
-- indent-blankline.nvim: Display indentation guides as vertical lines
-- 
-- Features:
--   - Shows vertical lines for each indentation level
--   - Helps visualize code structure and nesting
--   - Highlights the scope/context of the current code block
--   - Customizable appearance (colors, characters, etc.)
--   - Improves readability of nested code
--   - Works with all indentation styles (spaces and tabs)
--
-- This is especially helpful when:
--   - Working with deeply nested code
--   - Understanding the structure of configuration files
--   - Identifying matching indentation levels at a glance
--
-- Repo: https://github.com/lukas-reineke/indent-blankline.nvim
-- ============================================================================

return {
    'lukas-reineke/indent-blankline.nvim',
    -- Specify the main module name (for proper require() loading)
    -- This tells lazy.nvim to use 'ibl' instead of the plugin name
    main = 'ibl',
    -- opts = {}: Use default configuration
    -- The plugin works great with sensible defaults - no customization needed
    -- You can add custom options here if desired (e.g., colors, enabled filetypes)
    opts = {},
}
