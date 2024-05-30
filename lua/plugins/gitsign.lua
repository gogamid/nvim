return {
  -- git signs for nvim
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      -- center after next/prev hunk
      {
        "]h",
        mode = { "n" },
        function()
          require("gitsigns").next_hunk()
          vim.cmd("normal! zz")
        end,
      },
      {
        "[h",
        mode = { "n" },
        function()
          require("gitsigns").prev_hunk()
          vim.cmd("normal! zz")
        end,
      },
      { "<leader>ghs", mode = { "n", "v" }, ":Gitsigns stage_hunk<cr>" },
      { "<leader>ghr", mode = { "n", "v" }, ":Gitsigns reset_hunk<cr>" },
      { "<leader>ghS", mode = { "n" }, ":Gitsigns stage_buffer<cr>" },
      { "<leader>ghu", mode = { "n" }, ":Gitsigns undo_stage_hunk<cr>" },
      { "<leader>ghR", mode = { "n" }, ":Gitsigns reset_buffer<cr>" },
      { "<leader>ghp", mode = { "n" }, ":Gitsigns preview_hunk<cr>" },
      { "<leader>ghb", mode = { "n" }, ":lua require('gitsigns').blame_line({ full = true })<cr>" },
      { "<leader>ghd", mode = { "n" }, ":Gitsigns diffthis<cr>" },
      { "<leader>ghD", mode = { "n" }, ":lua require('gitsigns').diffthis('~')<cr>" },
      { "ih", mode = { "o", "x" }, ":Gitsigns select_hunk<cr>" },
    },
  },
}
