***REMOVED***

  -- add json to treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "json", "json5", "jsonc" ***REMOVED***)
  ***REMOVED***
***REMOVED***,
***REMOVED***

  -- correctly setup lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "b0o/SchemaStore.nvim",
      version = false, -- last release is way too old
  ***REMOVED***
    opts = {
      -- make sure mason installs the server
      servers = {
        jsonls = {
          -- lazy-load schemastore when needed
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {***REMOVED***
            vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
      ***REMOVED***,
          settings = {
            json = {
              format = {
                enable = true,
            ***REMOVED***
              validate = { enable = true ***REMOVED***,
          ***REMOVED***
        ***REMOVED***
      ***REMOVED***
    ***REMOVED***
  ***REMOVED***
***REMOVED***
***REMOVED***
