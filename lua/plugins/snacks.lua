return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>n", false },
      { "<leader>.", false }, --no scratch buffer
    },
    opts = {
      image = {},
      dashboard = {
        preset = {
          keys = {},
          header = require("custom.headers").neovim,
        },
        formats = { key = { "" } },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
      lazygit = {
        win = {
          width = 0.99,
          height = 0.99,
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
      bigfile = { enabled = false },
      notifier = {
        enabled = true,
        timeout = 3000,
        margin = { top = 0, right = 1, bottom = 1, left = 0 },
        top_down = false,
      },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      styles = {
        notification = {
          wo = { wrap = true }, -- Wrap notifications
        },
      },
      zen = {
        toggles = { dim = false },
      },
      input = { enabled = true },
      gitbrowse = {
        url_patterns = {
          ["dev%.azure%.com"] = {
            file = "?path=/{file}&version=GB{branch}&line={line_start}&lineEnd={line_end}&lineStartColumn=1&lineEndColumn=1&lineStyle=plain&_a=contents",
            commit = "/commit/{commit}",
            branch = "",
          },
        },
      },
    },
  },
}
