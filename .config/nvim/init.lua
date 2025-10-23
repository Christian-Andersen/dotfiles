-- ~/.config/nvim/init.lua

-- ======================================================================
-- 0. Bootstrap and Core Settings
-- ======================================================================

-- 0.11 Optimization: Enable loader
-- Enables the built-in Neovim module loader for potentially faster startup times.
if vim.loader then
	vim.loader.enable()
end

-- Leader Key
-- Sets the global leader key to <Space>. This key is used as a prefix for custom mappings.
vim.g.mapleader = " "
-- Sets the local leader key (used for buffer-local maps) to <Space> as well.
vim.g.maplocalleader = " "

-- Core Options
-- Enables standard line numbering in the current buffer.
vim.opt.number = true
-- Enables relative line numbering (lines above/below show distance, current line shows absolute number).
vim.opt.relativenumber = true
-- Enables mouse support in all modes ('a' stands for all).
vim.opt.mouse = "a"
-- Sets the number of spaces that a <Tab> character consumes visually.
vim.opt.tabstop = 4
-- Sets the number of spaces to use for auto-indentation (e.g., when pressing <CR> or using '>>').
vim.opt.shiftwidth = 4
-- Converts all typed <Tab> characters to spaces (soft tabs).
vim.opt.expandtab = true
-- Always show the sign column, even if there are no signs to display (prevents text from jumping).
vim.opt.signcolumn = "yes"
-- Minimum number of screen lines to keep above and below the cursor when scrolling.
vim.opt.scrolloff = 8
-- Time in milliseconds to wait before triggering events like 'CursorHold' or 'updatetime' (used by LSP/diagnostics).
vim.opt.updatetime = 250

-- Diagnostic configuration for how errors/warnings are displayed.
vim.diagnostic.config({
    -- Options for how diagnostics appear in the line (under the error/warning)
    virtual_text = true,
    -- Options for the sign column (the 'W' you are currently seeing)
    signs = true,
    -- Options for highlighting the text that triggered the diagnostic
    underline = true,
    -- Options for the floating window that appears when hovering
    float = {
        source = true, -- Show which LSP provided the diagnostic (e.g., [ruff])
        focusable = false,
        border = "single",
        -- Use a custom function to format the message nicely in the float
        format = function(diagnostic)
            local codes = diagnostic.code and "(" .. diagnostic.code .. ") " or ""
            return codes .. diagnostic.message
        end,
    },
})

-- ======================================================================
-- 1. Plugin Manager (Lazy.nvim)
-- ======================================================================

-- Defines the path where lazy.nvim should be installed in the Neovim data directory.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Checks if the lazy.nvim directory does not exist.
if not vim.loop.fs_stat(lazypath) then
	-- If it doesn't exist, execute a system command to clone the stable branch of the repository.
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none", -- Use partial clone for faster download.
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
-- Prepends the path of lazy.nvim to the Neovim runtime path so it can be loaded.
vim.opt.rtp:prepend(lazypath)

-- Define the list of plugins to be managed by lazy.nvim.
local plugins = {
	-- 1. Colorscheme
	{
		"folke/tokyonight.nvim",
		lazy = false, -- Load this plugin immediately at startup.
		priority = 1000, -- Ensures it loads very early to set the colorscheme quickly.
		config = function()
			-- Function executed after the plugin is loaded to set the colorscheme.
			vim.cmd.colorscheme("tokyonight")
		end,
	},

	-- 2. File Explorer
	{
		"nvim-tree/nvim-tree.lua",
		-- Commands that will trigger the loading of this plugin if used.
		cmd = { "NvimTreeToggle", "NvimTreeFocus" },
		-- Define keymaps for this plugin.
		keys = { { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle Explorer" } },
		-- Configuration options for nvim-tree.lua.
		opts = {
			disable_netrw = true, -- Disable the built-in netrw file explorer.
			hijack_netrw = true, -- Take over netrw functionality completely.
			sync_root_with_cwd = true, -- Keep the NvimTree root synchronized with the current working directory.
		},
	},

	-- 3. Telescope (Fuzzy Finder)
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope", -- Loads the plugin when the Telescope command is run.
		dependencies = { "nvim-lua/plenary.nvim" }, -- Required dependency for async functions.
		keys = {
			-- Keymap to find files in the current working directory.
			{ "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
			-- Keymap to search for text across files using live grep.
			{ "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live Grep" },
		},
		opts = {}, -- Empty options table (using default Telescope configuration).
	},

	-- 4. Which-Key (Keymap Visualizer)
	{
		"folke/which-key.nvim",
		event = "VeryLazy", -- Load after core configuration is done.
		config = function()
			local wk = require("which-key")
		end,
	},

	-- 4. LSP (Language Server Protocol)
	{
		"neovim/nvim-lspconfig",
		-- Load the plugin before reading any buffer or creating a new file.
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			-- Dependency for integrating LSP capabilities with nvim-cmp (autocompletion).
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			-- Get default LSP capabilities and modify them for nvim-cmp integration.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			-- Define a helper function to run when an LSP client attaches to a buffer.
			local on_attach = function(client, bufnr)
				-- Set LSP-specific keymaps (actual maps are defined in Section 3 and scoped to the buffer)
				-- This function is crucial for defining the buffer-local LSP keymaps.
			end

			-- Setup specific language servers manually
			-- NOTE: The servers (e.g., 'ruff', 'ty') must be installed globally or in your path.

			-- Setup the 'ruff' language server (for Python linting/formatting).
			vim.lsp.config["ruff"] = {
				on_attach = on_attach, -- Pass the on_attach function for keymaps.
				capabilities = capabilities, -- Pass the nvim-cmp-ready capabilities.
			}
			vim.lsp.enable("ruff")

			-- Setup the 'ty' language server (Typeform's server, perhaps used for a specific language/tool).
			vim.lsp.config["ty"] = {
				on_attach = on_attach, -- Pass the on_attach function for keymaps.
				capabilities = capabilities, -- Pass the nvim-cmp-ready capabilities.
				settings = {
					-- Pass specific settings to the 'ty' language server.
					ty = { experimental = { rename = true } },
				},
			}
			vim.lsp.enable("ty")
		end,
	},

	-- 5. Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter", -- Load the plugin when entering Insert mode.
		dependencies = {
			"hrsh7th/cmp-buffer", -- Source for completion from current buffer text.
			"hrsh7th/cmp-nvim-lsp", -- Source for completion from the LSP client.
			"L3MON4D3/LuaSnip", -- Snippet engine.
			"saadparwaiz1/cmp_luasnip", -- Integration between nvim-cmp and LuaSnip.
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				-- Snippet configuration, telling cmp to use LuaSnip to expand snippets.
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				-- Keymaps for interacting with the completion menu.
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(), -- Select next item.
					["<C-p>"] = cmp.mapping.select_prev_item(), -- Select previous item.
					["<C-Space>"] = cmp.mapping.complete(), -- Trigger completion popup manually.
					-- Confirm the selected item, and if a selection is made, accept it.
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				-- Define the sources to pull completion items from, in order of preference.
				sources = cmp.config.sources({
					{ name = "nvim_lsp" }, -- Completion provided by the Language Server.
					{ name = "luasnip" }, -- Completion from defined snippets.
					{ name = "buffer" }, -- Completion from words in the current buffer.
				}),
			})
		end,
	},
}

---

-- ======================================================================
-- 2. Lazy Setup
-- ======================================================================
-- Call the lazy.nvim setup function with the defined plugin list and options.
require("lazy").setup(plugins, {
	checker = { enabled = true, notify = false }, -- Enable automatic plugin updates checking without notification popups.
	performance = {
		rtp = {
			-- List of built-in plugins to prevent from loading (improves startup time).
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
})

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window Left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window Down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window Up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window Right" })

-- LSP Keymaps (Only on Attach)
-- Creates an Autocmd (Automatic Command) that runs when an LSP client successfully attaches to a buffer.
vim.api.nvim_create_autocmd("LspAttach", {
	-- Creates a new autogroup to manage these commands, preventing duplicate assignments.
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	-- The function to execute when the event fires.
	callback = function(ev)
		-- Options table that scopes the keymaps to the buffer (ev.buf) the LSP client attached to.
		local opts = { buffer = ev.buf }
		-- Maps 'gd' in Normal mode to go to the definition of the symbol under the cursor.
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		-- Maps 'K' in Normal mode to show hover documentation for the symbol under the cursor.
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		-- Maps <leader>rn in Normal mode to rename the symbol across the entire project.
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		-- Maps <leader>ca in Normal/Visual mode to show available code actions (e.g., quick fixes, refactoring).
		vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
	end,
})
