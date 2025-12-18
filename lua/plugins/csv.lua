return {
  {
    "hat0uma/csvview.nvim",
    config = function()
      require("csvview").setup({
        view = {
          display_mode = "border",
        },
        parser = {
          delimiter = {
            ft = {
              csv = ";",
              tsv = "\t",
            },
            fallbacks = {
              ",",
              "\t",
              ";",
              "|",
              ":",
              " ",
            },
          },
        },
      })
    end,
    ft = { "csv" },
    keys = {
      {
        "<leader>uc",
        function()
          require("csvview").toggle()
        end,
        desc = "Toggle Excel csvview",
      },
    },
  },
}
