---@param background? "dark" | "light
---@param contrast? "hard" | "medium" | "soft"
local function everforest(background, contrast)
  if not background then
    background = "dark"
  end
  if not contrast then
    contrast = "soft"
  end

  vim.cmd("set background=" .. background)
  vim.cmd(string.format("let g:everforest_background='%s'", contrast))
  vim.cmd([[
    let g:everforest_enable_italic = 1
    let g:everforest_disable_italic_comment = 1

    colorscheme everforest
  ]])
end

return {
  { "sainnhe/everforest" },
  { "rebelot/kanagawa.nvim" },
  { "rose-pine/neovim" },
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.cmd("colorscheme catppuccin-mocha")

        -- everforest("dark", "soft")
        --
        -- vim.cmd("highlight Normal guibg=none")
        -- vim.cmd("highlight NormalNC guibg=none")
        -- vim.cmd("highlight NormalSB guibg=none")
        -- vim.cmd("highlight NormalFloat guibg=none")
        -- vim.cmd("highlight Pmenu guibg=none")
        -- vim.cmd("highlight FloatBorder guibg=none")
        -- vim.cmd("highlight NonText guibg=none")
        -- vim.cmd("highlight Normal ctermbg=none")
        -- vim.cmd("highlight NonText ctermbg=none")
        -- vim.cmd("highlight EndOfBuffer guibg=none ctermbg=none")
        --
        -- vim.api.nvim_set_hl(0, "LspCodeLens", { link = "Conceal" })
        -- vim.api.nvim_set_hl(0, "LspCodeLensSeparator", { link = "Conceal" })
      end,
      set_light_mode = function()
        vim.cmd("colorscheme catppuccin-latte")
        -- everforest("light", "medium")

        -- vim.api.nvim_set_hl(0, "Visual", { bg = "#A7C080", fg = "#2B3339" })
      end,
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      transparent_background = true, -- disables setting the background color.
      color_overrides = {
        all = {
          rosewater = "#efd3cd",
          flamingo = "#ecc8c8",
          pink = "#e9c9e0",
          mauve = "#c4aee1",
          red = "#df99aa",
          maroon = "#e2a5ae",
          peach = "#ebb99b",
          yellow = "#eee3cd",
          green = "#6d9c6a",
          teal = "#a5ded4",
          sky = "#9dd8e3",
          sapphire = "#89c4e0",
          blue = "#96b9f1",
          lavender = "#b6bff5",
          text = "#afb4bc",
          subtext1 = "#bac2de",
          subtext0 = "#a6adc8",
          overlay2 = "#9399b2",
          overlay1 = "#7f849c",
          overlay0 = "#6c7086",
          surface2 = "#585b70",
          surface1 = "#45475a",
          surface0 = "#313244",
          base = "#1b1b20",
          mantle = "#19191f",
          crust = "#ffffff",
        },
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
          }
        end,
      },
    },
  },
}
