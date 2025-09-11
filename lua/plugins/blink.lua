return {
  "saghen/blink.cmp",
  version = "1.*",
  opts_extend = {
    "sources.completion.enabled_providers",
    "sources.compat",
    "sources.default",
  },
  event = "InsertEnter",

  opts = {
    snippets = {
      preset = "luasnip",
    },
    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = "mono",
    },
    completion = {
      trigger = {
        show_on_trigger_character = false,           -- Disable trigger chars like '.'
        show_on_keyword = true,                      -- Only show after typing keywords
        show_on_insert_on_trigger_character = false, -- Don't show immediately on '.'
      },
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        draw = {
          treesitter = {"lsp"},
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      ghost_text = {
        enabled = false,
      },
    },
    sources = {
      default = {"lsp", "path", "snippets", "buffer"},
      min_keyword_length = 2,
      providers = {
        snippets = {
          min_keyword_length = 2,
        },
        buffer = {
          min_keyword_length = 2,
          max_items = 2, -- Limit buffer suggestions
        },
      },
    },
    cmdline = {enabled = true},
    keymap = {
      preset = "enter",
      ["<C-y>"] = {"select_and_accept"},
    },
  },
  config = function(_, opts) require("blink.cmp").setup(opts) end,
}
