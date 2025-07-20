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
            default = ";",
            ft = {
              tsv = "\t",
            },
          },
        },
      })
    end,
    ft = { "csv" },
    keys = {
      {
        "<leader>ue",
        function()
          require("csvview").toggle()
        end,
        desc = "Toggle Excel csvview",
      },
    },
  },
}
