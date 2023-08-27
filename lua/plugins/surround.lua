***REMOVED***
  {
    "echasnovski/mini.surround",
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
      local opts = require("lazy.core.plugin").values(plugin, "opts", false)
      local mappings = {
  ***REMOVED*** opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" ***REMOVED*** ***REMOVED***,
  ***REMOVED*** opts.mappings.delete, desc = "Delete surrounding" ***REMOVED***,
  ***REMOVED*** opts.mappings.find, desc = "Find right surrounding" ***REMOVED***,
  ***REMOVED*** opts.mappings.find_left, desc = "Find left surrounding" ***REMOVED***,
  ***REMOVED*** opts.mappings.highlight, desc = "Highlight surrounding" ***REMOVED***,
  ***REMOVED*** opts.mappings.replace, desc = "Replace surrounding" ***REMOVED***,
  ***REMOVED*** opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" ***REMOVED***,
  ***REMOVED***
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
  ***REMOVED***, mappings)
      return vim.list_extend(mappings, keys)
***REMOVED***,
    opts = {
      mappings = {
        add = "gza", -- Add surrounding in Normal and Visual modes
        delete = "gzd", -- Delete surrounding
        find = "gzf", -- Find surrounding (to the right)
        find_left = "gzF", -- Find surrounding (to the left)
        highlight = "gzh", -- Highlight surrounding
        replace = "gzr", -- Replace surrounding
        update_n_lines = "gzn", -- Update `n_lines`
    ***REMOVED***
  ***REMOVED***
***REMOVED***
***REMOVED***
