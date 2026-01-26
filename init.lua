vim.g.minimal = false

if vim.g.minimal then
  require("minimal")
else
  require("config.options")
  require("config.keymaps")
  require("config.autocmds")
  require("config.lazy")
end
