-- lua/plugins/luasnip.lua
return {
  "L3MON4D3/LuaSnip",
  -- ... other settings ...
  config = function()
    -- Load our custom snippets
    --
    require("luasnip.loaders.from_vscode").lazy_load()
    -- require("config.snippets")
  end,
}
