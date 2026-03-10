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
    -- NEW: Image support (terminal dependent)
    image = { enabled = true },
    -- NEW: Toggle system
    toggle = { enabled = true },
  },
  keys = {
    -- Top Pickers & Explorer
    { "<leader><space>", function() Snacks.picker.buffers() end, desc = "Buffers [ ]" },
    { "<leader>sf", function() Snacks.picker.files() end, desc = "Search [f]iles" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Search by [g]rep" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command history [:]" },
    { "<leader>n", function() Snacks.notifier.show_history() end, desc = "[n]otification history" },
    { "<leader>e", function() Snacks.explorer() end, desc = "File [e]xplorer" },
    { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Search [t]odo comments" },
    { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIXME", "FIX" } }) end, desc = "Search [T]odo/Fixme" },
    -- Replicating existing Telescope bindings
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Search [h]elp" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Search [k]eymaps" },
    { "<leader>ss", function() Snacks.picker.pickers() end, desc = "Search [s]elect (pickers)" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Search current [w]ord", mode = { "n", "x" } },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Search [d]iagnostics" },
    { "<leader>sr", function() Snacks.picker.resume() end, desc = "Search [r]esume" },
    { "<leader>s.", function() Snacks.picker.recent() end, desc = "Search recent files [.]" },
    { "<leader>/", function() Snacks.picker.lines() end, desc = "Search buffer [/] lines" },
    { "<leader>s/", function() Snacks.picker.grep_buffers() end, desc = "Search open buffers [/]" },
    { "<leader>sn", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Search [n]eovim files" },
    -- Neo-tree replacement
    { "\\", function() Snacks.explorer() end, desc = "Toggle explorer [\\]" },

    -- Git
    { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git [b]lame line" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git [B]rowse" },
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazy[g]it" },
    { "<leader>gl", function() Snacks.lazygit.log() end, desc = "Lazygit [l]og (CWD)" },
    { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit current [f]ile history" },

    -- LSP (Global keys, replacing lspconfig buffer-local ones)
    { "gd", function() Snacks.picker.lsp_definitions() end, desc = "[g]oto [d]efinition" },
    { "gD", function() Snacks.picker.lsp_declarations() end, desc = "[g]oto [D]eclaration" },
    { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "[g]oto [r]eferences" },
    { "gI", function() Snacks.picker.lsp_implementations() end, desc = "[g]oto [I]mplementation" },
    { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "[g]oto t[y]pe definition" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP [s]ymbols" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP workspace [S]ymbols" },

    -- Toggles
    { "<leader>th", function() Snacks.toggle.inlay_hints():toggle() end, desc = "[t]oggle inlay [h]ints" },
    { "<leader>ts", function() Snacks.toggle.option("spell", { name = "Spelling" }):toggle() end, desc = "[t]oggle [s]pelling" },
    { "<leader>tw", function() Snacks.toggle.option("wrap", { name = "Wrap" }):toggle() end, desc = "[t]oggle [w]rap" },
    { "<leader>tr", function() Snacks.toggle.option("relativenumber", { name = "Relative Number" }):toggle() end, desc = "[t]oggle [r]elative number" },
    { "<leader>td", function() Snacks.toggle.diagnostics():toggle() end, desc = "[t]oggle [d]iagnostics" },
    { "<leader>tl", function() Snacks.toggle.line_number():toggle() end, desc = "[t]oggle [l]ine number" },
    { "<leader>tc", function() Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):toggle() end, desc = "[t]oggle [c]onceal" },

    -- Other
    { "<leader>z",  function() Snacks.zen() end, desc = "Toggle [z]en mode" },
    { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle [Z]oom" },
    { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle scratch buffer [.]" },
    { "<leader>S",  function() Snacks.scratch.select() end, desc = "[S]elect scratch buffer" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "[b]uffer [d]elete" },
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename file [R]" },
    { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle terminal [/]" },
    { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next reference []]]", mode = { "n", "t" } },
    { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev reference [[[]", mode = { "n", "t" } },
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
