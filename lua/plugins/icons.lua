-- local is_ssh = os.getenv("SSH_CONNECTION") ~= nil
local is_ssh = false --webssh supports icons

return {
  { "nvim-tree/nvim-web-devicons", enabled = not is_ssh },
  { "nvim-mini/mini.icons", opts = {
    style = is_ssh and "ascii" or "glyph",
  } },
}
