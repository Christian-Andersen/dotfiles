return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- Big File: Auto-disable features for large files
    bigfile = { enabled = true },
    -- Dashboard: Startup screen
    dashboard = { enabled = true },
    -- Explorer: File tree (replaces neo-tree)
    explorer = { enabled = true },
    -- Indent: Indent guides (replaces indent-blankline)
    indent = { enabled = true },
    -- Input: Better vim.ui.input
    input = { enabled = true },
    -- Picker: Fuzzy finder (replaces telescope)
    picker = { enabled = true },
    -- Notifier: Better vim.notify (replaces fidget & nvim-notify)
    notifier = { enabled = true },
    -- Quickfile: Fast startup for single files
    quickfile = { enabled = true },
    -- Scope: Highlight current scope
    scope = { enabled = true },
    -- Scroll: Smooth scrolling
    scroll = { enabled = true },
    -- Status Column: Modern status column
    statuscolumn = { enabled = true },
    -- Words: Auto-highlight LSP references
    words = { enabled = true },
    -- Git integration
    git = { enabled = true },
    gitbrowse = { enabled = true },
    lazygit = { enabled = true },
  },
  keys = {
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.buffers() end, desc = "Find Buffers" },
    { "<leader>sf", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
    { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo Comments" },
    { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIXME", "FIX" } }) end, desc = "Todo/Fixme" },
    -- Replicating existing Telescope bindings
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Search Help" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Search Keymaps" },
    { "<leader>ss", function() Snacks.picker.pickers() end, desc = "Search Select (Pickers)" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Search Current Word", mode = { "n", "x" } },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Search Diagnostics" },
    { "<leader>sr", function() Snacks.picker.resume() end, desc = "Search Resume" },
    { "<leader>s.", function() Snacks.picker.recent() end, desc = "Search Recent Files" },
    { "<leader>/", function() Snacks.picker.lines() end, desc = "Search Buffer Lines" },
    { "<leader>s/", function() Snacks.picker.grep_buffers() end, desc = "Search Open Buffers" },
    { "<leader>sn", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Search Config Files" },
    -- Neo-tree replacement
    { "\\", function() Snacks.explorer() end, desc = "Toggle Explorer" },

    -- Git
    { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse" },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit Log (CWD)" },
    { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },

    -- LSP (Global keys, replacing lspconfig buffer-local ones)
    { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
    { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
    { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },

    -- Other
    { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
    { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
    { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
    { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
    { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
    { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Debug helpers
        _G.dd = function(...) Snacks.debug.inspect(...) end
        _G.bt = function() Snacks.debug.backtrace() end
        vim.print = _G.dd
      end,
    })
  end,
}
