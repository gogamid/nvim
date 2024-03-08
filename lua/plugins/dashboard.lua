return {
  -- show day of the week in the dashboard
  {
    "nvimdev/dashboard-nvim",
    opts = function(_, opts)
      opts.config.week_header = {
        enable = true,
      }
    end,
  },
}
