return {
  { "nvim-lua/plenary.nvim" },
  { "mrjones2014/smart-splits.nvim" },
  { "MunifTanjim/nui.nvim" },
  { "kmonad/kmonad-vim" },
  { "rafamadriz/friendly-snippets" },
  {
    "nvzone/typr",
    dependencies = "nvzone/volt",
    opts = {},
    cmd = { "Typr", "TyprStats" },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        "lazy.nvim",
        "snacks.nvim",
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
