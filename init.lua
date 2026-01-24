if vim.g.vscode then
  vim.schedule(function()
    local cmd = { "osascript", "-e", 'display notification "vscode" with title "neovim"' }
    vim.system(cmd)
  end)
else
  require("config.options")
  require("config.autocmds")
  require("config.keymaps")
  require("config.lazy")
end
