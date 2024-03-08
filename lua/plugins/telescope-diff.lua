return {
  -- compare 2 files
  {
    "jemag/telescope-diff.nvim",
    dependencies = {
      { "nvim-telescope/telescope.nvim" },
    },
    keys = {
      {
        "<leader>fD",
        function() require("telescope").extensions.diff.diff_files { hidden = true } end,
        desc = "Compare 2 files",
      },
      {
        "<leader>fd",
        function() require("telescope").extensions.diff.diff_current { hidden = true } end,
        desc = "Compare file with current",
      },
    },
  },
}
