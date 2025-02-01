return {
  {
    "Willem-J-an/adopure.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      vim.g.adopure = {}
    end,
  },
}
