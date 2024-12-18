return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        enabled = true,
        preset = {
          header = [[ 
                                                                       
         ████ ██████           █████      ██                     
        ███████████             █████                             
        █████████ ███████████████████ ███   ███████████   
       ███:)████  ███    █████████████ █████ ██████████████   
      █████████ ██████████ █████████ █████ █████ ████ █████   
    ███████████ ███    ███ █████████ █████ █████ ████ █████  
   ██████  █████████████████████ ████ █████ █████ ████ ██████ 
                                                                         
]],
        },
        sections = {
          -- { section = "terminal", cmd = "fortune -s", hl = "header", padding = 1, indent = 8 },
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
          -- { section = "terminal", cmd = "fortune -s ", hl = "header", indent = 6 },
        },
      },
      lazygit = {
        win = {
          width = 0.9,
          height = 0.9,
        },
      },
      terminal = {
        win = {
          position = "float",
          relative = "editor",
          backdrop = 60,
          border = "rounded",
          height = 0.8,
          width = 0.95,
          zindex = 50,
          keys = {
            q = "close",
          },
        },
      },
      bigfile = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
        margin = { top = 0, right = 1, bottom = 1, left = 0 },
        top_down = false,
      },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      styles = {
        notification = {
          wo = { wrap = true }, -- Wrap notifications
        },
      },
      zen = {
        enabled = true,
      },
      input = {
        enabled = true,
        backdrop = false,
        position = "float",
        border = "rounded",
        title_pos = "left",
        height = 1,
        width = 60,
        relative = "editor",
        row = 2,
        -- relative = "cursor",
        -- row = -3,
        -- col = 0,
        wo = {
          winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
        },
        keys = {
          i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i" },
          -- i_esc = { "<esc>", "stopinsert", mode = "i" },
          i_cr = { "<cr>", { "cmp_accept", "confirm" }, mode = "i" },
          i_tab = { "<tab>", { "cmp_select_next", "cmp" }, mode = "i" },
          q = "cancel",
        },
      },
    },
  },
}
