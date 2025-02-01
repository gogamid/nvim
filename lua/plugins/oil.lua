return {
  {
    "stevearc/oil.nvim",
    enabled = false,
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      skip_confirm_for_simple_edits = true,
      float = {
        max_width = 0.8,
        max_height = 0.8,
      },
    },
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
    keys = {
      {
        "<leader>e",
        function()
          require("oil").open_float()
          -- Snacks.picker.explorer()
        end,
        "Open oil file viewer",
      },
    },
  },
}
