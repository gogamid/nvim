return {
  { "tpope/vim-dadbod" },
  { "kristijanhusak/vim-dadbod-completion" },
  { "kristijanhusak/vim-dadbod-ui" },
  -- { dir = "~/personal/nvim-plugins/sql-ghosty.nvim", opts = {
  --
  --   highlight_group = "conceal",
  -- } },
  {
    "pmouraguedes/sql-ghosty.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
  },
}
