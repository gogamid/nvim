return {
  {
    "hat0uma/csvview.nvim",
    ft = { "csv" },
    opts = {
      view = {
        display_mode = "border",
        min_column_width = 1,
      },
      parser = {
        delimiter = {
          ft = {
            -- csv = ";",
          },
        },
      },
    },
    keys = {
      {
        "<leader>uc",
        function()
          require("csvview").toggle()
        end,
        desc = "Toggle CSV View",
      },
    },
  },
}
