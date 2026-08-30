return {
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.o.background = "dark"
        local img = vim.fn.stdpath("config") .. "/backgrounds/flexoki-dark-orb.png"
        vim.fn.system(
          'osascript -e \'tell application "System Events" to tell every desktop to set picture to "' .. img .. "\"'"
        )
      end,
      set_light_mode = function()
        vim.o.background = "light"
        local img = vim.fn.stdpath("config") .. "/backgrounds/flexoki-light-orb.png"
        vim.fn.system(
          'osascript -e \'tell application "System Events" to tell every desktop to set picture to "' .. img .. "\"'"
        )
      end,
    },
  },
  {
    "mcchrish/zenbones.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.flexoki = { italic_strings = true, transparent_background = true, darkness = "warm", lightness = "dim" }
      vim.cmd.colorscheme("flexoki")
    end,
  },
}
