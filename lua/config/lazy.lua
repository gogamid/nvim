local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath ***REMOVED***)
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    -- import any extras modules here
    { "LazyVim/LazyVim", import = "lazyvim.plugins" ***REMOVED***,
    { import = "lazyvim.plugins.extras.lang.python" ***REMOVED***,
    { import = "lazyvim.plugins.extras.coding.copilot" ***REMOVED***,
    { import = "lazyvim.plugins.extras.dap.core" ***REMOVED***,
    { import = "lazyvim.plugins.extras.lang.json" ***REMOVED***,
    { import = "lazyvim.plugins.extras.lang.java" ***REMOVED***,
    -- { import = "lazyvim.plugins.extras.ui.mini-animate" ***REMOVED***,
    -- import/override with your plugins
    { import = "plugins" ***REMOVED***,
***REMOVED***
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
***REMOVED***
  install = { colorscheme = { "tokyonight", "habamax" ***REMOVED*** ***REMOVED***,
  checker = { enabled = true ***REMOVED***, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
    ***REMOVED***
  ***REMOVED***
***REMOVED***
***REMOVED***)
