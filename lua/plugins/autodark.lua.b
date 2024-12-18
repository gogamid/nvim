local function changeTheme(theme)
  local opts = require("catppuccin").options
  if theme == "dark" then
    opts.transparent_background = true
    opts.flavour = "mocha"
  else
    opts.transparent_background = false
    opts.flavour = "latte"
  end
  require("catppuccin").setup(opts)
end

return {
  {
    "f-person/auto-dark-mode.nvim",
    dependencies = { "catppuccin/nvim" },
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        changeTheme("dark")
        vim.opt.background = "dark"
      end,
      set_light_mode = function()
        changeTheme("light")
        vim.opt.background = "light"
      end,
    },
  },
}
