return {
  {
    "JellyApple102/easyread.nvim",
    enabled = false,
    opts = {
      fileTypes = {"text", "markdown"},
    },
    keys = {
      {"<leader>uE", ":EasyreadToggle<CR>", desc = "Toggle Easyread"},
    },
  },

  {
    "nullchilly/fsread.nvim",
    ft = "markdown",
    keys = {
      {"<leader>uB", ":FSToggle<CR>", desc = "Toggle Bionic Read"},
    },
    config = function(_, opts)
      vim.g.flow_strength = 0.5 -- low: 0.3, middle: 0.5, high: 0.7 (default)
      vim.api.nvim_set_hl(0, "FSPrefix", {fg = "#cdd6f4"})
      vim.api.nvim_set_hl(0, "FSSuffix", {fg = "#6C7086"})
    end,
  },
  {
    "HampusHauffman/bionic.nvim",
    enabled = false,
    keys = {
      {"<leader>uB", ":Bionic<CR>", desc = "Toggle Bionic Read"},
    },
  },
}
