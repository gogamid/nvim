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
      vim.g.zenbones = { italic_strings = true, transparent_background = true, darkness = "warm", lightness = "dim" }

      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "zenbones",
        callback = function()
          local lush = require("lush")
          local zb = require("zenbones")
          local stringColor = vim.o.background == "light" and "#4F6C30" or "#819B69"
          local specs = lush.parse(function()
            return {
              String({ zb.String, fg = stringColor }),
              SnacksPicker({ bg = "NONE" }),
              NormalFloat({ bg = "NONE" }),
              FloatBorder({ zb.FloatBorder, bg = "NONE" }),
              DebugPrintLine({ zb.DiagnosticHint, bg = "NONE" }),
            }
          end)
          lush.apply(lush.compile(specs))
        end,
      })
      vim.cmd.colorscheme("zenbones")
    end,
  },
}
