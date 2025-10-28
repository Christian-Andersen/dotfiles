-- ============================================================================
-- AUTOPAIRS PLUGIN
-- ============================================================================
-- nvim-autopairs: Automatically pair brackets, parentheses, quotes, and more
-- 
-- Features:
--   - Auto-closes matching pairs: (), [], {}, '', "", ``
--   - Handles smart indentation when inserting pairs
--   - Integrates with completion engines (blink-cmp in this config)
--   - Works in insert and replace modes
--   - Can be extended with custom rules
--
-- Repo: https://github.com/windwp/nvim-autopairs
-- ============================================================================

return {
    -- The main plugin specification
    'windwp/nvim-autopairs',
    -- Load the plugin when entering insert mode
    -- This is efficient because autopairs is only needed when typing
    event = 'InsertEnter',
    -- opts = {}: Use default configuration
    -- Autopairs works out of the box with sensible defaults
    -- Advanced users can customize behavior here (e.g., disable for specific filetypes)
    opts = {},
}
