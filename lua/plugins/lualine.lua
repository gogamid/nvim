***REMOVED***
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      local Util = require("lazyvim.util")
      local colors = {
        [""] = Util.fg("Special"),
        ["Normal"] = Util.fg("Special"),
        ["Warning"] = Util.fg("DiagnosticError"),
        ["InProgress"] = Util.fg("DiagnosticWarn"),
  ***REMOVED***
      table.insert(opts.sections.lualine_x, 2, {
        function()
          local icon = require("lazyvim.config").icons.kinds.Copilot
          local status = require("copilot.api").status.data
          return icon .. (status.message or "")
    ***REMOVED***,
        cond = function()
          local ok, clients = pcall(vim.lsp.get_active_clients, { name = "copilot", bufnr = 0 ***REMOVED***)
          return ok and #clients > 0
    ***REMOVED***,
        color = function()
          if not package.loaded["copilot"] then
            return
      ***REMOVED***
          local status = require("copilot.api").status.data
          return colors[status.status] or colors[""]
    ***REMOVED***,
  ***REMOVED***)
***REMOVED***,
***REMOVED***
  -- the opts function can also be used to change the default opts:
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, "😄")
***REMOVED***,
***REMOVED***
***REMOVED***
