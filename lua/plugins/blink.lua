return {
  "saghen/blink.cmp",
  build = "cargo build --release",
  opts_extend = {
    "sources.completion.enabled_providers",
    "sources.compat",
    "sources.default",
  },
  opts = {
    snippets = { preset = "luasnip" },
    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = "mono",
    },
    completion = {
      list = {
        selection = {
          preselect = true,
        },
      },
      trigger = {
        show_on_trigger_character = false, -- Disable trigger chars like '.'
        show_on_keyword = true, -- Only show after typing keywords
        show_on_insert_on_trigger_character = false, -- Don't show immediately on '.'
      },
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        auto_show = function(ctx, items)
          return vim.bo.filetype ~= "markdown"
        end,

        draw = {
          treesitter = { "lsp" },
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
      default = { "lsp", "path", "snippets", "buffer" },
      min_keyword_length = 2,
      providers = {
        snippets = {
          min_keyword_length = 2,
        },
        buffer = {
          min_keyword_length = 3,
          max_items = 2, -- Limit buffer suggestions
        },
      },
    },
    keymap = {
      preset = "enter",
    },
    cmdline = {
      keymap = {
        preset = "none",
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<Tab>"] = { "show_and_insert_or_accept_single", "select_next" },
        ["<S-Tab>"] = { "show_and_insert_or_accept_single", "select_prev" },
        ["<C-space>"] = { "show", "fallback" },
        ["<C-e>"] = { "cancel", "fallback" },
      },
    },
  },
}
