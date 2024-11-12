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
}
