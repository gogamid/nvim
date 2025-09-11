return {
  "andrewferrier/debugprint.nvim",
  dependencies = {
    "echasnovski/mini.hipatterns", -- Optional: Needed for line highlighting ('fine-grained' hipatterns plugin)
    "folke/snacks.nvim",           -- Optional: If you want to use the `:Debugprint search` command with snacks.nvim
  },
  lazy = false,                    -- Required to make line highlighting work before debugprint is first used
  opts = {
    keymaps = {
      normal = {
        variable_below = "<leader>rp",
        variable_above = "<leader>rP",
        plain_below = "<leader>re",
        plain_above = "",
        variable_below_alwaysprompt = "",
        variable_above_alwaysprompt = "",
        surround_plain = "",
        surround_variable = "",
        surround_variable_alwaysprompt = "",
        textobj_below = "",
        textobj_above = "",
        textobj_surround = "",
        toggle_comment_debug_prints = "",
        delete_debug_prints = "<leader>rc",
      },
      insert = {
        plain = "",
        variable = "",
      },
      visual = {
        variable_below = "<leader>rp",
        variable_above = "<leader>rP",
      },
    },
    -- display_counter = counter_func,
    display_snippet = false,
    filetypes = {
      ["go"] = {},
    },
  },
}
