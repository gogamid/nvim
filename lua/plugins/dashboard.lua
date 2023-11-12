return {
  {
    "nvimdev/dashboard-nvim",
    opts = function(_, opts)
      opts.config.week_header = {
        enable = true,
      }
    end,
  },
}
