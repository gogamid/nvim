return {
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        win = {
          width = 0.98,
          height = 0.9,
        },
      },
      terminal = {
        win = {
          position = "float",
          relative = "editor",
          backdrop = 60,
          height = 0.8,
          width = 0.8,
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
      },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      styles = {
        notification = {
          wo = { wrap = true }, -- Wrap notifications
        },
      },
    },
  },
}
