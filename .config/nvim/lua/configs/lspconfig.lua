require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "ty" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 

local lspconfig = require("lspconfig")
lspconfig.ty.setup({
  filetypes = { "python" },
  settings = {
    ty = {
      experimental = {
        rename = true, 
      },
    },
  },
})
