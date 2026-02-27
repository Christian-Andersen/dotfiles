-- ============================================================================
-- DEBUG ADAPTER PROTOCOL (DAP)
-- ============================================================================
-- Configures debugging support for Neovim.
--
-- Plugins:
--   - nvim-dap: Core DAP client
--   - nvim-dap-view: UI for debugging (variables, stack frames, etc.)
--   - nvim-dap-python: Python-specific DAP configuration
--   - mason-nvim-dap: Bridges Mason and nvim-dap
--
-- Features:
--   - Breakpoints (F9, Leader+db)
--   - Stepping (F10, F11, F12)
--   - Auto-open debug view on start
--   - Break on uncaught exceptions (auto-debug on crash)
-- ============================================================================

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI for DAP
      "igorlfs/nvim-dap-view",
      -- Python debugging support
      "mfussenegger/nvim-dap-python",
      -- Mason integration
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      local dap = require("dap")
      local dap_view = require("dap-view")

      -- Mason Setup
      -- Ensures debugpy is installed
      require("mason-nvim-dap").setup({
        ensure_installed = { "python" },
        handlers = {},
      })

      -- DAP View Setup
      -- Simple, clean UI for debugging
      dap_view.setup()

      -- Python Setup
      -- Update the path to point to the mason installed debugpy
      -- This path is standard for Mason on Linux
      local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(mason_path)

      -- Keymaps
      -- F5: Start debugging or continue
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
      -- F10: Step Over
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
      -- F11: Step Into
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
      -- F12: Step Out
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
      -- Leader+db: Toggle Breakpoint
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      -- Leader+dB: Set Conditional Breakpoint
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Debug: Set Conditional Breakpoint" })
      -- Leader+dv: Toggle Debug View manually
      vim.keymap.set("n", "<leader>dv", dap_view.toggle, { desc = "Debug: Toggle View" })
      -- Leader+dx: Terminate Debug Session
      vim.keymap.set("n", "<leader>dx", dap.terminate, { desc = "Debug: Terminate/Exit" })

      -- Automation: Open View on Start
      dap.listeners.after.event_initialized["dap_view_config"] = function()
        dap_view.open()
      end

      -- Automation: Break on Uncaught Exceptions
      -- This satisfies the "auto-debug on error" requirement.
      -- When the debugger is running, if an exception is uncaught, it will pause.
      dap.listeners.after.event_initialized["dap_exception_config"] = function()
        dap.set_exception_breakpoints({ "uncaught" })
      end

      -- Aesthetics: Custom Icons
      vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶️", texthl = "", linehl = "", numhl = "" })
    end,
  },
}
