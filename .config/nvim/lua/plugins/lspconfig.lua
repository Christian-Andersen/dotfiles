-- ============================================================================
-- LSP CONFIGURATION (Language Server Protocol)
-- ============================================================================
-- nvim-lspconfig: Configures language servers for IntelliSense and diagnostics
--
-- Features:
--   - Code completion, type hints, and parameter info
--   - Goto definition, references, implementations
--   - Rename variables and apply code actions (refactorings)
--   - Real-time error/warning/info diagnostics
--   - Symbol navigation within files and workspace
--   - Hover documentation
--
-- LSP Keybindings:
--   grn  : Rename symbol
--   gra  : Code action (refactorings, fixes)
--   grr  : Find references
--   gri  : Go to implementation
--   grd  : Go to definition
--   grD  : Go to declaration
--   gO   : Document symbols (outline)
--   gW   : Workspace symbols
--   grt  : Go to type definition
--   <leader>th : Toggle inline type hints
--
-- Repos: https://github.com/neovim/nvim-lspconfig
--        https://github.com/mason-org/mason.nvim
-- ============================================================================

return {
    'neovim/nvim-lspconfig',
    dependencies = {
        -- Mason: Package manager for LSPs, formatters, linters, and DAP adapters
        { 'mason-org/mason.nvim', opts = {} },
        -- Mason LSPConfig: Bridges Mason and lspconfig for easy server setup
        'mason-org/mason-lspconfig.nvim',
        -- Mason Tool Installer: Auto-installs tools (formatters, linters, etc.)
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        -- Fidget: Shows LSP progress notifications during initialization
        { 'j-hui/fidget.nvim',    opts = {} },
        -- Blink.cmp: Completion engine that integrates with LSP
        'saghen/blink.cmp',
    },
    config = function()
        -- ===== LSP KEYBINDINGS =====
        -- Set up keybindings when an LSP attaches to a buffer
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
            callback = function(event)
                -- Helper to create LSP keybindings for this buffer
                local map = function(keys, func, desc, mode)
                    mode = mode or 'n' -- Default to normal mode
                    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                end

                -- Rename: Rename the symbol under cursor throughout the file
                map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
                -- Code Actions: Show available refactorings and fixes (works in normal and visual mode)
                map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
                -- References: Find all places where this symbol is used
                map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                -- Implementations: Find all implementations of this interface/abstract method
                map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
                -- Definitions: Jump to where this symbol is defined
                map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                -- Declaration: Jump to where this symbol is declared
                map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                -- Document Symbols: Show outline/symbols in current file (like ctags)
                map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
                -- Workspace Symbols: Search for symbols across the entire workspace/project
                map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
                -- Type Definition: Jump to the type definition of the symbol under cursor
                map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

                -- Helper function to check if a language server supports a capability
                local function client_supports_method(client, method, bufnr)
                    return client:supports_method(method, bufnr)
                end

                -- Get the language server client for this buffer
                local client = vim.lsp.get_client_by_id(event.data.client_id)

                -- ===== DOCUMENT HIGHLIGHTING =====
                -- Highlight all references to the symbol under the cursor
                if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
                    local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight',
                        { clear = false })
                    -- Highlight when cursor is held (not moving)
                    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    -- Clear highlighting when cursor moves
                    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })

                    -- Clean up highlighting when LSP detaches
                    vim.api.nvim_create_autocmd('LspDetach', {
                        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
                        end,
                    })
                end

                -- ===== INLAY HINTS =====
                -- Toggle inline type hints (if the language server supports them)
                -- Type hints show inferred types like: function(x: number) or var = 42
                if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
                    map('<leader>th', function()
                        -- Toggle inlay hints on/off for this buffer
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
                    end, '[T]oggle Inlay [H]ints')
                end
            end,
        })

        -- ===== DIAGNOSTIC DISPLAY CONFIGURATION =====
        -- Configure how LSP diagnostics (errors, warnings, info, hints) are displayed
        vim.diagnostic.config {
            -- Sort diagnostics by severity (errors first, then warnings, then info, then hints)
            severity_sort = true,
            -- Configure the floating window that appears when hovering over diagnostics
            float = {
                border = 'rounded', -- Use rounded borders for a modern look
                source = 'if_many', -- Show the source (e.g., \"pylint\") only if multiple diagnostics
            },
            -- Only underline errors (not warnings or info)
            underline = { severity = vim.diagnostic.severity.ERROR },
            -- Configure the signs (symbols) shown in the gutter for diagnostics
            signs = vim.g.have_nerd_font and {
                text = {
                    [vim.diagnostic.severity.ERROR] = '󰅚 ', -- Red X for errors
                    [vim.diagnostic.severity.WARN] = '󰀪 ', -- Yellow warning for warnings
                    [vim.diagnostic.severity.INFO] = '󰋽 ', -- Blue info for info
                    [vim.diagnostic.severity.HINT] = '󰌶 ', -- Purple hint for hints
                },
            } or {}, -- Empty table if no Nerd Font (uses default symbols)
            -- Virtual text: Shows diagnostic messages inline (at the end of the line)
            virtual_text = {
                source = 'if_many', -- Show source only when there are multiple diagnostics
                spacing = 2,        -- Space between error code and message
            },
        }

        -- ===== LANGUAGE SERVER CONFIGURATIONS =====
        -- Define which language servers to use and their settings
        local servers = {
            -- Ruff: Fast Python linter (for style checking)
            ruff = {}, -- Empty config = use defaults

            -- Ty: Modern Python language server (type checking and analysis)
            ty = {
                cmd = { 'ty', 'server' },                               -- Command to start the server
                filetypes = { 'python' },                               -- Only load for Python files
                root_markers = { 'pyproject.toml', 'uv.lock', '.git' }, -- Find project root by these files
                settings = {
                    ty = {
                        experimental = {
                            rename = true, -- Enable experimental rename functionality
                        },
                    },
                },
            },

            -- Lua LS: Language server for Lua
            lua_ls = {
                settings = {
                    Lua = {
                        -- Use snippet completion (show function signatures, insert params)
                        completion = { callSnippet = 'Replace' },
                    },
                },
            },
        }

        -- ===== AUTO-INSTALL LANGUAGE SERVERS AND TOOLS =====
        -- Collect all server names that need to be installed
        local ensure_installed = vim.tbl_keys(servers or {})
        -- Also ensure stylua (Lua formatter) is installed
        vim.list_extend(ensure_installed, { 'stylua' })
        -- Tell Mason to auto-install all the tools
        require('mason-tool-installer').setup { ensure_installed = ensure_installed }

        -- ===== ENABLE LANGUAGE SERVERS =====
        -- Configure and enable each language server
        for name, config in pairs(servers) do
            -- Add completion capabilities from blink.cmp to the LSP config
            config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
            -- Set this server's configuration
            vim.lsp.config[name] = config
            -- Enable the language server (start it when needed)
            vim.lsp.enable(name)
        end
    end,
}
