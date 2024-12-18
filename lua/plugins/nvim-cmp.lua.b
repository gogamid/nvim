local cmp = require("cmp")
return {
  {
    "hrsh7th/nvim-cmp",
    opts = {
      completion = { completeopt = "menu,menuone,noinsert,noselect" },
      preselect = require("cmp").PreselectMode.None,
    },
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      --disable C-y, used by supermaven
      opts.mapping["<C-y>"] = nil
    end,
  },
}
