return {
  "nvim-treesitter/nvim-treesitter",
  -- opts = {
  --   ensure_installed = "maintained",
  -- },
    opts = function(_, opts)
-- extend ensure_installed with http
      opts.ensure_installed = {
        "http",
      }
    end,
}

