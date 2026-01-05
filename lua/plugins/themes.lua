return {
  {
    "mcchrish/zenbones.nvim",
    dependencies = "rktjmp/lush.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.zenbones = { italic_strings = false, transparent_background = false }
      vim.cmd("colorscheme zenbones")

      local lush = require("lush")
      local zb = require("zenbones")

      local specs = lush.parse(function()
        return {
          String({ zb.String, fg = "#819B69" }),
        }
      end)
      lush.apply(lush.compile(specs))
    end,
  },
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.o.background = "dark"
      end,
      set_light_mode = function()
        vim.o.background = "light"
      end,
    },
  },
  {
    "ribru17/bamboo.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function(_, opts)
      require("bamboo").setup(opts)
    end,
  },
  {
    "slugbyte/lackluster.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
  },
}
