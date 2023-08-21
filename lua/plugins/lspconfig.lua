***REMOVED***
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {***REMOVED***,
        ruff_lsp = {***REMOVED***,
    ***REMOVED***
  ***REMOVED***
    setup = {
      ruff_lsp = function()
        require("lazyvim.util").on_attach(function(client, _)
          if client.name == "ruff_lsp" then
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
      ***REMOVED***
    ***REMOVED***)
  ***REMOVED***,
  ***REMOVED***
***REMOVED***
***REMOVED***
