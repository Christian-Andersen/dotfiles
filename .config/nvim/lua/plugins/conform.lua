-- ============================================================================
-- CONFORM CODE FORMATTER
-- ============================================================================
-- conform.nvim: A lightweight and extensible code formatter
-- 
-- Features:
--   - Supports multiple formatters per language
--   - Format on save (can be disabled per filetype)
--   - LSP formatter fallback
--   - Async formatting to avoid blocking the editor
--   - Easy to configure and extend
--
-- Repo: https://github.com/stevearc/conform.nvim
-- ============================================================================

return {
    'stevearc/conform.nvim',
    -- Load on BufWritePre (before writing buffer to file)
    -- This enables format-on-save functionality
    event = { 'BufWritePre' },
    -- Also load when :ConformInfo command is used
    -- Useful for checking formatter status without triggering lazy loading
    cmd = { 'ConformInfo' },
    
    -- Keybindings for manual formatting
    keys = {
        {
            -- Leader+f maps to format the entire buffer
            '<leader>f',
            function()
                -- async = true: format without blocking the UI
                -- lsp_format = 'fallback': use LSP formatter if no formatter is configured
                require('conform').format { async = true, lsp_format = 'fallback' }
            end,
            mode = '',  -- Works in normal, insert, visual modes
            desc = '[F]ormat buffer',
        },
    },
    
    -- Configuration options
    opts = {
        -- Don't show error notifications if formatting fails
        notify_on_error = false,
        
        -- Auto-format on save (can be disabled for specific filetypes)
        format_on_save = function(bufnr)
            -- Disable auto-format for C and C++ files
            -- (they often have specific formatting requirements)
            local disable_filetypes = { c = true, cpp = true }
            if disable_filetypes[vim.bo[bufnr].filetype] then
                return nil  -- Don't format for these filetypes
            else
                -- For other filetypes, format with these settings:
                return {
                    timeout_ms = 500,      -- Wait max 500ms for formatter to complete
                    lsp_format = 'fallback', -- Use LSP formatter if no formatter is configured
                }
            end
        end,
        
        -- Define which formatters to use for each filetype
        formatters_by_ft = {
            -- Use stylua (Lua formatter) for Lua files
            lua = { 'stylua' },
            -- You can add more filetypes here, e.g.:
            -- python = { 'black', 'isort' },
            -- javascript = { 'prettier' },
            -- json = { 'prettier' },
        },
    },
}
