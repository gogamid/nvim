return {
  { "tpope/vim-dadbod" },
  { "kristijanhusak/vim-dadbod-completion" },
  { "kristijanhusak/vim-dadbod-ui" },
  {
    "pmouraguedes/sql-ghosty.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      highlight_group = "Comment",
    },
  },
}
