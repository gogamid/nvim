return {
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
    "mcchrish/zenbones.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.zenbones = { italic_strings = true, transparent_background = false, darkness = "stark" }
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
              FloatBorder({ zb.FlotBorder, bg = "NONE" }),
            }
          end)
          lush.apply(lush.compile(specs))
          vim.api.nvim_set_hl(0, "DebugPrintLine", { link = "DiagnosticHint" })
        end,
      })
      vim.cmd.colorscheme("zenbones")
    end,
  },
  {
    "oskarnurm/koda.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      -- require("koda").setup({ transparent = true })
      vim.cmd("colorscheme koda")
    end,
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
    init = function()
      vim.cmd("colorscheme lackluster")
    end,
  },
}
