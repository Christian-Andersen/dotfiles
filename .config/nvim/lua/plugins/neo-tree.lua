-- ============================================================================
-- NEO-TREE FILE BROWSER
-- ============================================================================
-- neo-tree.nvim: Modern and feature-rich file tree browser for Neovim
--
-- Features:
--   - Browse file system with an expanding tree view
--   - Create, rename, delete files and directories
--   - Git status indicators (modified, added, ignored, etc.)
--   - Quick preview of files
--   - Toggle hidden files
--   - Fuzzy search within tree
--   - Customizable appearance and behavior
--   - Multiple sources (filesystem, buffers, git status)
--
-- Keybindings:
--   \         : Toggle neo-tree file browser
--   (in tree) : various navigation and file operations
--
-- Repo: https://github.com/nvim-neo-tree/neo-tree.nvim
-- ============================================================================

return {
    'nvim-neo-tree/neo-tree.nvim',
    -- Use latest stable version (all versions)
    version = '*',

    -- Required dependencies
    dependencies = {
        -- Utility library for plugin development in Neovim
        'nvim-lua/plenary.nvim',
        -- Web dev icons for file type icons in the tree
        'nvim-tree/nvim-web-devicons',
        -- NUI: UI components library for building Neovim UIs
        'MunifTanjim/nui.nvim',
    },

    -- Don't lazy load - load immediately on startup
    -- Having the file tree available immediately is important for browsing the project
    lazy = false,

    -- Keybindings to open/toggle neo-tree
    keys = {
        {
            '\\',                  -- Backslash as the toggle key
            ':Neotree reveal<CR>', -- Command to open neo-tree and reveal current file
            desc = 'NeoTree reveal',
            silent = true,         -- Don't echo the command
        },
    },

    -- Configuration options
    opts = {
        -- Configure the filesystem source (file tree view)
        filesystem = {
            window = {
                -- Custom keybindings within the neo-tree window
                mappings = {
                    -- Pressing \ in the tree closes the window (toggles it)
                    ['\\'] = 'close_window',
                },
            },
        },
    },
}
