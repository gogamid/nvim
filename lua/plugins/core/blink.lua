return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts = {
      fuzzy = { implementation = "prefer_rust" },
      snippets = { preset = "luasnip" },
      completion = {
        -- list = {
        --   max_items = 6,
        -- },
        documentation = {
          auto_show = true,
        },
        menu = {
          auto_show = function(_, _)
            local disabled = { "markdown" }
            return not vim.tbl_contains(disabled, vim.bo.filetype)
          end,
        },
      },
      sources = {
        min_keyword_length = 2,
        -- providers = {
        --   snippets = {
        --     score_offset = 1000,
        --   },
        -- },
      },
      signature = {
        enabled = true,
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
          ["<C-n>"] = { "select_next", "fallback" },
          ["<C-p>"] = { "select_prev", "fallback" },
          ["<C-space>"] = { "show", "fallback" },
          ["<C-e>"] = { "cancel", "fallback" },
        },
      },
    },
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function(_, opts)
      require("luasnip").setup(opts)
      require("luasnip.loaders.from_vscode").lazy_load() -- friendly snippets

      local snippets_path = vim.fn.stdpath("config") .. "/snippets"
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { snippets_path } })
      require("luasnip.loaders.from_lua").lazy_load({ paths = { snippets_path } })
    end,
  },
}
