return {
  { "Mofiqul/vscode.nvim" },
  { "sainnhe/everforest" },
  { "EdenEast/nightfox.nvim" },
  { "folke/tokyonight.nvim" },
  { "rose-pine/neovim", name = "rose-pine" },
  { "projekt0n/github-nvim-theme", name = "github-theme" },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    -- priority = 1000,
    -- opts = {
    --   transparent_background = true,
    --   custom_highlights = {
    --     CursorLineNr = { bg = "none", fg = "#d2a4fd" },
    --     --   CursorLine = { bg = u.blend(colors.mauve, colors.base, 0.10) },
    --   },
    -- },
  },
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        vim.cmd("colorscheme catppuccin-mocha")
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        vim.cmd("colorscheme dayfox")
      end,
    },
  },
}
