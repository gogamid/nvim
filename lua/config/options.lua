-------------------------------------------------- CORE --------------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.autoindent = true

vim.opt.clipboard = "unnamedplus"

-------------------------------------------------- QOL --------------------------------------------------------------------------------
vim.opt.scrolloff = 10 -- Keep 10 lines above/below cursor

vim.o.wrap = false
vim.o.breakindent = true -- Indent wrapped lines to match line start
vim.o.linebreak = true -- Wrap lines at 'breakat' (if 'wrap' is set)

vim.o.splitbelow = true -- Horizontal splits will be below
vim.o.splitright = true -- Vertical splits will be to the right

vim.o.foldmethod = "indent" -- Fold based on indent level
vim.opt.foldlevel = 99 -- Do not fold by default

vim.o.ignorecase = true -- Ignore case during search
vim.o.smartcase = true -- Respect case if search pattern has upper case

vim.opt.autoread = true -- Auto reload files changed outside vim
vim.opt.autochdir = true

vim.o.confirm = true -- ":q" and ":e" will ask for confirmation
vim.opt.writebackup = false -- Don't create backup before writing
vim.opt.swapfile = false -- Don't create swap files
vim.o.undofile = true -- Enable persistent undo

vim.o.winborder = "single"

vim.opt.fillchars = {
  eob = " ",
  diff = "╱",
  foldopen = "",
  foldclose = "",
  foldsep = "▕",
}

vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "ErrorMsg",
      [vim.diagnostic.severity.WARN] = "WarningMsg",
    },
  },
})

------------------------------------------------- CUSTOM -------------------------------------------------------------------------------
vim.g.icons_enabled = true

if vim.g.neovide then
  vim.g.transparency = 0.8
  vim.g.neovide_opacity = 0.2
  vim.g.neovide_normal_opacity = 0.6
  vim.g.neovide_show_border = false
  vim.g.neovide_background_color = "#2A3035"
end

vim.filetype.add({
  extension = {
    apt = "gupta",
  },
  pattern = {
    [".*%.apt%.indented"] = "gupta",
  },
})
