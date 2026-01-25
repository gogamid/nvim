return {
  "andrewferrier/debugprint.nvim",
  dependencies = {
    "nvim-mini/mini.hipatterns",
    "folke/snacks.nvim",
  },
  lazy = false,
  opts = {
    display_counter = false,
    display_location = false,
    picker = "snacks.picker",
    filetypes = {
      ["lua"] = {
        left = "vim.notify('",
      },
    },
    keymaps = {
      normal = {
        variable_below = "<leader>rv",
        surround_variable = "<leader>rV",
        plain_below = "<leader>rp",
        surround_plain = "<leader>rP",
        toggle_comment_debug_prints = "<leader>rc",
        delete_debug_prints = "<leader>rd",

        plain_above = "",
        variable_above = "",
        variable_below_alwaysprompt = "",
        variable_above_alwaysprompt = "",
        surround_variable_alwaysprompt = "",
        textobj_below = "",
        textobj_above = "",
        textobj_surround = "",
      },
      insert = {
        plain = "",
        variable = "",
      },
      visual = {
        variable_below = "<leader>rv",
        variable_above = "",
      },
    },
  },
}
