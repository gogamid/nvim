return {
  {
    "hat0uma/csvview.nvim",
    config = function()
      require("csvview").setup({
        view = {
          display_mode = "border",
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
        "Toggle Excel csvview",
      },
    },
  },
}
