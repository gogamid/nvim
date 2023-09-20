if vim.g.vscode then
  print("You are using Nvim vscode extension")
  require("config.vscode.init")
else
  local isPersonal = vim.fn.isdirectory("C:/Users/dtwj6af") ~= 0
  print(isPersonal)
  require("config.lazy")
end
