return {
  "L3MON4D3/LuaSnip",
  dependencies = {"rafamadriz/friendly-snippets"},
  config = function(_, opts)
    require("luasnip").setup(opts)
    require("luasnip.loaders.from_vscode").lazy_load() -- friendly snippets

    local snippets_path = vim.fn.stdpath("config") .. "/snippets"
    require("luasnip.loaders.from_vscode").lazy_load({paths = {snippets_path}})
    require("luasnip.loaders.from_lua").lazy_load({paths = {snippets_path}})
  end,
}
