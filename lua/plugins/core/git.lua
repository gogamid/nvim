return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
    keys = {
      -- Navigation
      {
        "]c",
        function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            require("gitsigns").nav_hunk("next")
          end
        end,
        desc = "Next Hunk",
      },
      {
        "[c",
        function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            require("gitsigns").nav_hunk("prev")
          end
        end,
        desc = "Prev Hunk",
      },
      -- Actions
      { "<leader>hs", ":Gitsigns stage_hunk<CR>", desc = "Stage Hunk" },
      { "<leader>hr", ":Gitsigns reset_hunk<CR>", desc = "Reset Hunk" },
      {
        "<leader>hs",
        function()
          require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end,
        mode = "v",
        desc = "Stage Hunk",
      },
      {
        "<leader>hr",
        function()
          require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end,
        mode = "v",
        desc = "Reset Hunk",
      },
      { "<leader>hS", ":Gitsigns stage_buffer<CR>", desc = "Stage Buffer" },
      { "<leader>hR", ":Gitsigns reset_buffer<CR>", desc = "Reset Buffer" },
      { "<leader>hp", ":Gitsigns preview_hunk<CR>", desc = "Preview Hunk" },
      { "<leader>hi", ":Gitsigns preview_hunk_inline<CR>", desc = "Preview Hunk Inline" },
      {
        "<leader>hb",
        function()
          require("gitsigns").blame_line({ full = true })
        end,
        desc = "Blame Line",
      },
      { "<leader>hd", ":Gitsigns diffthis ~<CR>" },
      { "<leader>hq", ":Gitsigns setqflist<CR>", desc = "Set Quickfixlist" },
      { "<leader>hQ", ":Gitsigns setqflist all<CR>", desc = "Set Quickfixlist All" },
      -- Toggles
      {
        "<leader>ugb",
        function()
          require("gitsigns").toggle_current_line_blame()
        end,
        desc = "Toggle Current Line Blame",
      },
      {
        "<leader>ugw",
        function()
          require("gitsigns").toggle_word_diff()
        end,
        desc = "Toggle Word Diff",
      },
      -- Text object
      {
        "ih",
        function()
          require("gitsigns").select_hunk()
        end,
        mode = { "o", "x" },
        desc = "Select Hunk",
      },
    },
  },
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
  },
}
