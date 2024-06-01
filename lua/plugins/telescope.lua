return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        path_display = {
          "filename_first",
        },
      },
    },
    keys = {
      {
        "<leader>fP",
        function()
          require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
        end,
        desc = "Find Plugin File",
      },
    },
  },
  {
    "jemag/telescope-diff.nvim",
    dependencies = {
      { "nvim-telescope/telescope.nvim" },
    },
    keys = {
      {
        "<leader>fD",
        function()
          require("telescope").extensions.diff.diff_files({ hidden = true })
        end,
        desc = "Compare 2 files",
      },
      {
        "<leader>fd",
        function()
          require("telescope").extensions.diff.diff_current({ hidden = true })
        end,
        desc = "Compare file with current",
      },
    },
  },
}
