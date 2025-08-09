return {
  {
    "L3MON4D3/LuaSnip",
    config = function()
      local snippets_path = vim.fn.stdpath("config") .. "/snippets"
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { snippets_path } })
      require("luasnip.loaders.from_lua").lazy_load({ paths = { snippets_path } })
    end,
  },
  { "rafamadriz/friendly-snippets" },
}
