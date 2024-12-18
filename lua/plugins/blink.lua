return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        -- ["<C-y>"] = { "accept", "fallback" },
        -- ["<CR>"] = {},
      },
      enabled = function()
        return not vim.tbl_contains({ "DressingInput" }, vim.bo.filetype)
          and vim.bo.buftype ~= "prompt"
          and vim.b.completion ~= false
      end,
    },
    -- version = "v0.7.0",
  },
}
