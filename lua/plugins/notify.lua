***REMOVED***
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.5)
  ***REMOVED***,
      max_width = function()
        return math.floor(vim.o.columns * 0.5)
  ***REMOVED***,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 ***REMOVED***)
  ***REMOVED***,
  ***REMOVED***
***REMOVED***
***REMOVED***
