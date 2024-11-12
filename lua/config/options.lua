-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt
opt.termguicolors = true

opt.relativenumber = false

-- python
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff_lsp"
local home = os.getenv("HOME")
vim.g.python3_host_prog = home .. "/.pyenv/versions/pynvim/bin/python"

--add lines to lualine
opt.fillchars = {
  stl = "─",
  stlnc = "─",
}

opt.wrap = true
