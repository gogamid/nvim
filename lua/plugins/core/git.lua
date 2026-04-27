return {
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
    },
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
    "sindrets/diffview.nvim",
    keys = {
      {
        "<leader>gdw",
        ":DiffviewOpen<CR>",
        desc = "Diff working tree vs staged/index",
      },
      {
        "<leader>gds",
        ":DiffviewOpen HEAD<CR>",
        desc = "Diff staged changes (index) against the last commit (HEAD)",
      },
      {
        "<leader>gdo",
        ":DiffviewOpen origin/main..HEAD<CR>",
        desc = "Diff origin/main",
      },
    },
  },
  {
    "esmuellert/codediff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = "CodeDiff",
  },
}
