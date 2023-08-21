-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd({ "BufEnter" ***REMOVED***, {
  pattern = { "*.md" ***REMOVED***,
  callback = function(args)
    local wk = require("which-key")
    wk.register({
      ["<localleader>"] = {
        r = {
          ":!pandoc -t revealjs -s -o index.html % --highlight=zenburn -V revealjs-url=https://unpkg.com/reveal.js/ -V theme=solarized<CR>",
          "Export to revealjs",
      ***REMOVED***
    ***REMOVED***
  ***REMOVED*** {
      buffer = args.buf,
***REMOVED***)
***REMOVED***
***REMOVED***)
