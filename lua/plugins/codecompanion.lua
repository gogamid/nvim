return {
  "olimorris/codecompanion.nvim",
  enabled = true,
  config = true,
  dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
  opts = {
    sources = {
      per_filetype = {
        codecompanion = { "codecompanion" },
      },
    },
    display = {
      chat = {
        window = {
          layout = "float",
        },
      },
    },
  },
}
