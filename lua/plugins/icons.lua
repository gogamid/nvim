local is_ssh = os.getenv("SSH_CONNECTION") ~= nil or os.getenv("TERM_PROGRAM") == "Termius"

return {
  { "nvim-tree/nvim-web-devicons", enabled = not is_ssh },
  { "nvim-mini/mini.icons", opts = {
    style = is_ssh and "ascii" or "glyph",
  } },
}
