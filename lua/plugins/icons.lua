return {
  { "nvim-tree/nvim-web-devicons", enabled = vim.g.icons_enabled },
  { "nvim-mini/mini.icons", opts = {
    style = vim.g.icons_enabled and "glyph" or "ascii",
  } },
}
