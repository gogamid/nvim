return {
  {
    "nvim-lualine/lualine.nvim",
    optional = false,
    opts = {
      options = {
        component_separators = { left = "╲", right = "╱" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        -- remove time in favor of tmux status line date
        lualine_z = {},
      },
    },
  },
}
