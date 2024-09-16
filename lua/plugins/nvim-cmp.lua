return {
  {
    "hrsh7th/nvim-cmp",
    opts = {
      mapping = {
        -- ["<CR>"] = require("cmp").config.disable,
      },
      -- do not select middle
      completion = { completeopt = "menu,menuone,noinsert,noselect" },
      preselect = require("cmp").PreselectMode.None,
    },
  },
  {
    "hrsh7th/nvim-cmp",
    -- we just need one trash suggestion per each
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "codeium",
        group_index = 1,
        max_item_count = 1,
      })
    end,
  },
}
