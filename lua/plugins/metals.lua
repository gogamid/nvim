return {
  "scalameta/nvim-metals",
  keys = {
    { "<leader>cW", function() require("metals").hover_worksheet() end, desc = "Metals Worksheet" },
    {
      "<leader>cM",
      function() require("telescope").extensions.metals.commands() end,
      desc = "Telescope Metals Commands",
    },
  },
}
