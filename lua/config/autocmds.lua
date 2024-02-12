-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = { "scala", "sbt"},
--   callback = function()
--     require("metals").initialize_or_attach({})
--   end,
--   group = augroup("metals"),
-- })

-- vim.api.nvim_create_autocmd("BufWritePost", {
--   pattern = { "*.tex" },
--   callback = function()
--     local file = vim.fn.expand('%:p')
--     vim.fn.system('lualatex '..file)
--     vim.fn.system('rm '..file:gsub(".tex", ".log"))
--     --sleep 1 second to wait for the pdf to be created
--     local pdf = string.gsub(file, ".tex", ".pdf")
--     if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
--       vim.fn.system('start "" "'..pdf..'"')
--     else
--       vim.fn.system('open "'..pdf..'"')
--     end
--   end,
--   group = augroup("lualatex"),
-- })
