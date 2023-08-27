-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true ***REMOVED***)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt", "java" ***REMOVED***,
  callback = function()
    require("metals").initialize_or_attach({***REMOVED***)
***REMOVED***
  group = augroup("metals"),
***REMOVED***)
