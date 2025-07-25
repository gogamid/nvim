local c = {

  truffle = "#605F4B",
  truffle_1 = "#4B4A39",
  truffle_2 = "#333326",
  sage = "#9C9E80",

  oyster = "#F9F4EA",
  oyster_1 = "#E0D6C3",
  oyster_2 = "#C7B89C",
  oyster_3 = "#A89972",
  oyster_4 = "#8C7A4F",
  oyster_5 = "#6E5C2B",

  copper = "#DBB887",
  copper_1 = "#C99A5B",
  copper_2 = "#B68036",

  terracotta = "#C47457",
  rust = "#8B4D2E",

  rosewater = "#f2d5cf",
  flamingo = "#eebebe",
  pink = "#f4b8e4",
  red = "#e78284",
  maroon = "#ea999c",
  peach = "#ef9f76",
  yellow = "#e5c890",
  green = "#a6d189",
  teal = "#81c8be",
  sky = "#99d1db",
  sapphire = "#85c1dc",
  lavender = "#babbf1",
  blue = "#8caaee",
  mauve = "#ca9ee6",
}
---@diagnostic disable: unused-function, unused-local
local ok_everforest = pcall(require, "everforest")

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

local function transparent()
  vim.cmd([[
    highlight Normal guibg=NONE ctermbg=NONE
    highlight EndOfBuffer guibg=NONE ctermbg=NONE
    highlight NonText ctermbg=NONE
    highlight WinSeparator guibg=None  " Remove borders for window separators
    highlight SignColumn guibg=None " Remove background from signs column
    highlight NvimTreeWinSeparator guibg=None
    highlight NvimTreeEndOfBuffer guibg=None
    highlight NvimTreeNormal guibg=None
  ]])
end

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
    lazy = false,
    name = "catppuccin",
    priority = 1000,
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
          -- yellow = "#e5c890",
          yellow = c.copper,
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

      -- theme & transparency
      vim.keymap.set("n", "<leader>uc", function()
        if vim.g.appearance == "dark" then
          vim.g.appearance = "light"
          vim.o.background = "light" -- For a light background
          vim.cmd.colorscheme("catppuccin-latte")
          print("now light theme")
        elseif vim.g.appearance == "light" then
          vim.g.appearance = "dark"
          vim.cmd.colorscheme("catppuccin-frappe")
          -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
          -- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
          -- vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
          print("now dark theme")
        end
      end, { desc = "Toggle light/dark colorscheme" })
    end,
  },

  { "sainnhe/everforest" },
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        -- vim.o.background = "dark"
        vim.g.appearance = "dark"
        vim.cmd("colorscheme catppuccin-frappe")
        --
        -- everforest("dark", "hard")
      end,
      set_light_mode = function()
        -- vim.g.appearance = "light"
        -- vim.o.background = "light"
        -- vim.cmd("colorscheme catppuccin-latte")
        everforest("light", "soft")
      end,
    },
  },
}
