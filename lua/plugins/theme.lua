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
}
return {
  {
    "catppuccin/nvim",
    lazy = false,
    name = "catppuccin",
    priority = 1000,
    opts = {
      background = { light = "latte", dark = "frappe" }, -- latte, frappe, macchiato, mocha
      show_end_of_buffer = false,
      transparent_background = false,
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

      color_overrides = {
        frappe = {
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
          -- blue = "#8caaee",
          -- lavender = "#babbf1",
          blue = c.terracotta,
          lavender = c.oyster,

          -- text = "#c6d0f5",
          -- subtext1 = "#b5bfe2",
          -- subtext0 = "#a5adce",
          text = c.oyster,
          subtext1 = c.oyster_1,
          subtext0 = c.oyster_2,

          -- overlay2 = "#949cbb",
          -- overlay1 = "#838ba7",
          -- overlay0 = "#737994",
          overlay2 = c.oyster_3,
          overlay1 = c.oyster_4,
          overlay0 = c.oyster_5,

          -- surface2 = "#626880",
          -- surface1 = "#51576d",
          -- surface0 = "#414559",
          surface2 = c.copper,
          surface1 = c.copper_1,
          surface0 = c.copper_2,

          -- base = "#303446",
          -- mantle = "#292c3c",
          -- crust = "#232634",
          base = c.truffle,
          mantle = c.truffle_1,
          crust = c.truffle_2,
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
      vim.g.appearance = "dark"
      vim.cmd.colorscheme("catppuccin-frappe")
      -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      -- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
      -- vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
      vim.keymap.set("n", "<leader>uc", function()
        if vim.g.appearance == "dark" then
          vim.g.appearance = "light"
          vim.cmd.colorscheme("catppuccin-latte")
          vim.o.background = "light" -- For a light background
          -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
          -- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
          -- vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
          print("now light theme")
        elseif vim.g.appearance == "light" then
          vim.g.appearance = "dark"
          vim.cmd.colorscheme("catppuccin-frappe")
          vim.o.background = "dark" -- For a dark background
          -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
          -- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
          -- vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
          print("now dark theme")
        end
      end, { desc = "Toggle light/dark colorscheme" })
    end,
  },
}
