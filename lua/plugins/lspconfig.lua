***REMOVED***
  -- add pyright to lspconfig
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
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

  -- add tsserver and setup with typescript.nvim instead of lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").on_attach(function(_, buffer)
          -- stylua: ignore
          vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" ***REMOVED***)
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer ***REMOVED***)
    ***REMOVED***)
  ***REMOVED***,
  ***REMOVED***
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- tsserver will be automatically installed with mason and loaded with lspconfig
        tsserver = {***REMOVED***,
    ***REMOVED***
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        -- example to setup with typescript.nvim
        tsserver = function(_, opts)
          require("typescript").setup({ server = opts ***REMOVED***)
          return true
    ***REMOVED***,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
    ***REMOVED***
  ***REMOVED***
***REMOVED***
***REMOVED***
