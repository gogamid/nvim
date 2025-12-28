local function set_transparent_background(val)
  local opts = require("catppuccin").options
  opts.transparent_background = val
  require("catppuccin").setup(opts)
end
return {
  {
    "ribru17/bamboo.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("bamboo").setup({})
      require("bamboo").load()
    end,
  },
  { "sainnhe/everforest" },
  { "rose-pine/neovim" },
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
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      color_overrides = {
        -- frappe = {
        --   rosewater = "#efd3cd",
        --   flamingo = "#ecc8c8",
        --   pink = "#e9c9e0",
        --   mauve = "#c4aee1",
        --   red = "#df99aa",
        --   maroon = "#e2a5ae",
        --   peach = "#ebb99b",
        --   yellow = "#eee3cd",
        --   green = "#6d9c6a",
        --   teal = "#a5ded4",
        --   sky = "#9dd8e3",
        --   sapphire = "#89c4e0",
        --   blue = "#96b9f1",
        --   lavender = "#b6bff5",
        --   text = "#afb4bc",
        --   subtext1 = "#bac2de",
        --   subtext0 = "#a6adc8",
        --   overlay2 = "#9399b2",
        --   overlay1 = "#7f849c",
        --   overlay0 = "#6c7086",
        --   surface2 = "#585b70",
        --   surface1 = "#45475a",
        --   surface0 = "#313244",
        --   base = "#1b1b20",
        --   mantle = "#19191f",
        --   crust = "#ffffff",
        -- },
        -- latte = {
        --   rosewater = "#dc8a78",
        --   flamingo = "#dd7878",
        --   pink = "#ea76cb",
        --   mauve = "#8839ef",
        --   red = "#d20f39",
        --   maroon = "#e64553",
        --   peach = "#fe640b",
        --   yellow = "#df8e1d",
        --   green = "#40a02b",
        --   teal = "#179299",
        --   sky = "#04a5e5",
        --   sapphire = "#209fb5",
        --   blue = "#1e66f5",
        --   lavender = "#7287fd",
        --   text = "#4c4f69",
        --   subtext1 = "#5c5f77",
        --   subtext0 = "#6c6f85",
        --   overlay2 = "#7c7f93",
        --   overlay1 = "#8c8fa1",
        --   overlay0 = "#9ca0b0",
        --   surface2 = "#acb0be",
        --   surface1 = "#bcc0cc",
        --   surface0 = "#ccd0da",
        --   base = "#eff1f5",
        --   mantle = "#e6e9ef",
        --   crust = "#dce0e8",
        -- },
      },
      custom_highlights = function(c)
        return {
          Comment = { fg = c.overlay0 },
        }
      end,
      highlight_overrides = {
        mocha = function(c)
          return {
            SnacksIndentScope = { fg = c.overlay1 },
            LspCodeLens = { fg = c.surface1 },
            LspCodeLensSeparator = { fg = c.surface2 },
          }
        end,
      },
    },
  },
}
