return {
  { "Mofiqul/vscode.nvim" },
  {
    "sainnhe/everforest",
    -- config = function(_, opts)
    --   vim.g.everforest_transparent_background = 1
    -- end,
  },
  { "folke/tokyonight.nvim" },
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("github-theme").setup({
        -- options = {
        --   transparent = true,
        -- },
      })
    end,
  },
}
