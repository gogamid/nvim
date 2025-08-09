return {
  {
    "L3MON4D3/LuaSnip",
    config = function()
      local snippets_path = vim.fn.stdpath("config") .. "/snippets"
      --json snippets
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { snippets_path } })
      -- advanced snippets
      require("luasnip.loaders.from_lua").lazy_load({ paths = { snippets_path } })
    end,
  },
  -- {
  --   "rafamadriz/friendly-snippets",
  --   config = function()
  --     -- load snippets from the snippets folder
  --     require("luasnip.loaders.from_vscode").lazy_load()
  --     require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
  --   end,
  -- },
}
