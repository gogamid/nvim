***REMOVED***
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {***REMOVED***,
        ruff_lsp = {
        ***REMOVED***
      ***REMOVED***
              "<leader>co",
              function()
                vim.lsp.buf.code_action({
                  apply = true,
                  context = {
                    only = { "source.organizeImports" ***REMOVED***,
                    diagnostics = {***REMOVED***,
                ***REMOVED***
            ***REMOVED***)
          ***REMOVED***,
              desc = "Organize Imports",
          ***REMOVED***
        ***REMOVED***
      ***REMOVED***
    ***REMOVED***
      setup = {
        ruff_lsp = function()
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "ruff_lsp" then
              -- Disable hover in favor of Pyright
              client.server_capabilities.hoverProvider = false
        ***REMOVED***
      ***REMOVED***)
    ***REMOVED***,
    ***REMOVED***
  ***REMOVED***
***REMOVED***
***REMOVED***
