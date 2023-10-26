***REMOVED***
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function()
      local logo = [[
          ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ 
          ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ 
          ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ 
          ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ 
          ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ 
          ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ 
    ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"

      local opts = {
        theme = "doom",
        hide = {
          -- this is taken care of by lualine
          -- enabling this messes up the actual laststatus setting after loading a file
          statusline = false,
      ***REMOVED***
        config = {
          header = vim.split(logo, "\n"),
        -- stylua: ignore
        center = {
    ***REMOVED*** action = "Telescope find_files",                                     desc = " Find file",       icon = " ", key = "f" ***REMOVED***,
    ***REMOVED*** action = "ene | startinsert",                                        desc = " New file",        icon = " ", key = "n" ***REMOVED***,
    ***REMOVED*** action = "Telescope oldfiles",                                       desc = " Recent files",    icon = " ", key = "r" ***REMOVED***,
    ***REMOVED*** action = "Telescope live_grep",                                      desc = " Find text",       icon = " ", key = "g" ***REMOVED***,
    ***REMOVED*** action = [[lua require("lazyvim.util").telescope.config_files()()]], desc = " Config",          icon = " ", key = "c" ***REMOVED***,
    ***REMOVED*** action = 'lua require("persistence").load()',                        desc = " Restore Session", icon = " ", key = "s" ***REMOVED***,
    ***REMOVED*** action = "LazyExtras",                                               desc = " Lazy Extras",     icon = " ", key = "x" ***REMOVED***,
    ***REMOVED*** action = "Lazy",                                                     desc = " Lazy",            icon = "󰒲 ", key = "l" ***REMOVED***,
    ***REMOVED*** action = "qa",                                                       desc = " Quit",            icon = " ", key = "q" ***REMOVED***,
      ***REMOVED***
          footer = function()
            local stats = require("lazy").stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            ***REMOVED*** "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" ***REMOVED***
      ***REMOVED***,
      ***REMOVED***
  ***REMOVED***
      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
        button.key_format = "  %s"
  ***REMOVED***

      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "DashboardLoaded",
          callback = function()
            require("lazy").show()
      ***REMOVED***,
    ***REMOVED***)
  ***REMOVED***

      return opts
***REMOVED***,
***REMOVED***
***REMOVED***
