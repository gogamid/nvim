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
  {
    "catppuccin/nvim",
    enabled = false,
    name = "catppuccin",
    opts = {
      background = { light = "latte", dark = "frappe" }, -- latte, frappe, macchiato, mocha
      show_end_of_buffer = false,
      transparent_background = true,
      styles = {
        comments = { "italic" },
        functions = { "bold" },
        keywords = { "italic" },
        operators = { "bold" },
        conditionals = { "bold" },
        loops = { "bold" },
        booleans = { "bold", "italic" },
        numbers = {},
        types = {},
        strings = {},
        variables = {},
        properties = {},
      },

      highlight_overrides = {
        frappe = function(frappe)
          return {
            Visual = { fg = frappe.rosewater },
          }
        end,
      },
      color_overrides = {
        frappe = {
          rosewater = "#e6cfc3", -- warm, soft highlight (10%)
          flamingo = "#e9a07b", -- accent, earthy orange (10%)
          pink = "#e6b7a9", -- muted, warm pink (10%)
          red = "#b4635a", -- clay red (10%)
          maroon = "#a05d56", -- deep earth red (10%)
          peach = "#e2b97f", -- warm peach (10%)
          yellow = "#d9c97c", -- muted yellow (10%)
          green = "#6e8b57", -- olive green (main accent, 30%)
          teal = "#5e8d87", -- muted teal (10%)
          sky = "#8caeaf", -- dusty sky blue (10%)
          sapphire = "#7a9e99", -- muted blue-green (10%)
          lavender = "#b3b9a5", -- soft, earthy lavender (10%)
          blue = "#7d8c8f", -- slate blue (10%)
          mauve = "#b49fa3", -- muted mauve (10%)
        },
        mocha = {
          rosewater = "#f2d5cf",
          flamingo = "#eebebe",
          pink = "#f4b8e4",
          mauve = "#ca9ee6",
          red = "#e78284",
          maroon = "#ea999c",
          peach = "#ef9f76",
          yellow = "#e5c890",
          green = "#a6d189",
          teal = "#81c8be",
          sky = "#99d1db",
          sapphire = "#85c1dc",
          blue = "#8caaee",
          lavender = "#babbf1",

          text = "#c6d0f5",
          subtext1 = "#b5bfe2",
          subtext0 = "#a5adce",

          overlay2 = "#949cbb",
          overlay1 = "#838ba7",
          overlay0 = "#737994",

          surface2 = "#626880",
          surface1 = "#51576d",
          surface0 = "#414559",

          base = "#303446",
          mantle = "#292c3c",
          crust = "#232634",
        },
      },
      integrations = {
        blink_cmp = true,
        grug_far = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        snacks = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
    end,
  },
  { "sainnhe/everforest" },
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        -- vim.cmd("colorscheme catppuccin-frappe")
        --
        everforest("dark", "hard")

        vim.cmd("highlight Normal guibg=none")
        vim.cmd("highlight NormalNC guibg=none")
        vim.cmd("highlight NormalSB guibg=none")
        vim.cmd("highlight NormalFloat guibg=none")
        vim.cmd("highlight Pmenu guibg=none")
        vim.cmd("highlight FloatBorder guibg=none")
        vim.cmd("highlight NonText guibg=none")
        vim.cmd("highlight Normal ctermbg=none")
        vim.cmd("highlight NonText ctermbg=none")
        vim.cmd("highlight EndOfBuffer guibg=none ctermbg=none")
      end,
      set_light_mode = function()
        -- vim.cmd("colorscheme catppuccin-latte")
        everforest("light", "medium")

        vim.api.nvim_set_hl(0, "Visual", { bg = "#A7C080", fg = "#2B3339" })
      end,
    },
  },
}
