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
          vim.cmd "normal! zz"
        end,
      },
      {
        "[h",
        mode = { "n" },
        function()
          require("gitsigns").prev_hunk()
          vim.cmd "normal! zz"
        end,
      },
      { "<leader>ghs", mode = { "n", "v" }, "<cmd>Gitsigns stage_hunk<cr>" },
      { "<leader>ghr", mode = { "n", "v" }, "<cmd>Gitsigns reset_hunk<cr>" },
      { "<leader>ghS", mode = { "n" }, "<cmd>Gitsigns stage_buffer<cr>" },
      { "<leader>ghu", mode = { "n" }, "<cmd>Gitsigns undo_stage_hunk<cr>" },
      { "<leader>ghR", mode = { "n" }, "<cmd>Gitsigns reset_buffer<cr>" },
      { "<leader>ghp", mode = { "n" }, "<cmd>Gitsigns preview_hunk<cr>" },
      { "<leader>ghb", mode = { "n" }, "<cmd>lua require('gitsigns').blame_line({ full = true })<cr>" },
      { "<leader>ghd", mode = { "n" }, "<cmd>Gitsigns diffthis<cr>" },
      { "<leader>ghD", mode = { "n" }, "<cmd>lua require('gitsigns').diffthis('~')<cr>" },
      { "ih", mode = { "o", "x" }, "<cmd>Gitsigns select_hunk<cr>" },
    },
  },
}
