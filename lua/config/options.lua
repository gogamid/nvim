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

opt.fillchars = {
  -- lualine lines
  stl = "─",
  stlnc = "─",
  -- folds
  eob = " ",
  diff = "╱",
  foldopen = "",
  foldclose = "",
  foldsep = "▕",
}

opt.wrap = false

--disable ai cmp only virtual text
vim.g.ai_cmp = false

-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1
--
---- Enable Treesitter folding initially
-- vim.wo.foldmethod = "expr"
-- vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
--
vim.g.snacks_animate = false
-- opt.spell = true

--on change of directory add to zoxide
vim.g.zoxide_hook = "pwd"

-- vim.diagnostic.config({
--   -- Use the default configuration
--   -- virtual_lines = true,
--
--   -- Alternatively, customize specific options
--   virtual_lines = {
--     -- Only show virtual line diagnostics for the current cursor line
--     current_line = true,
--   },
-- })
--
--with tiny
-- vim.diagnostic.config({ virtual_text = false, virtual_lines = false })
--
-- vim.g.root_spec = { "cwd", "lsp", { ".git", "lua" } }
