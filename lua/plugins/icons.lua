return {
  { "nvim-tree/nvim-web-devicons", enabled = not is_ssh },
  { "nvim-mini/mini.icons", opts = {
    style = vim.g.icons_enabled and "glyph" or "ascii",
  } },
}
