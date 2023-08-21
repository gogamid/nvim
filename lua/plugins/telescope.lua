***REMOVED***
  -- change some telescope options and a keymap to browse plugin files
  {
    "nvim-telescope/telescope.nvim",
  ***REMOVED***
      -- add a keymap to browse plugin files
      -- stylua: ignore
***REMOVED***
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root ***REMOVED***) end,
        desc = "Find Plugin File",
    ***REMOVED***
  ***REMOVED***
    -- change some options
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" ***REMOVED***,
        sorting_strategy = "ascending",
        winblend = 0,
    ***REMOVED***
  ***REMOVED***
***REMOVED***

  -- add telescope-fzf-native
  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    ***REMOVED***
        require("telescope").load_extension("fzf")
  ***REMOVED***,
  ***REMOVED***
***REMOVED***
***REMOVED***
