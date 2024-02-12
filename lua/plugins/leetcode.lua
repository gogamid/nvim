return {
  {
    "kawre/leetcode.nvim",
    build = ":TSUpdate html",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim", -- required by telescope
      "MunifTanjim/nui.nvim",

      -- optional
      "nvim-treesitter/nvim-treesitter",
      "rcarriga/nvim-notify",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>lq", mode = { "n" }, "<cmd>Leet tabs<cr>" },
      { "<leader>lm", mode = { "n" }, "<cmd>Leet menu<cr>" },
      { "<leader>lc", mode = { "n" }, "<cmd>Leet console<cr>" },
      { "<leader>lh", mode = { "n" }, "<cmd>Leet info<cr>" },
      { "<leader>ll", mode = { "n" }, "<cmd>Leet lang<cr>" },
      { "<leader>ld", mode = { "n" }, "<cmd>Leet desc<cr>" },
      { "<leader>lr", mode = { "n" }, "<cmd>Leet run<cr>" },
      { "<leader>ls", mode = { "n" }, "<cmd>Leet submit<cr>" },
      { "<leader>ly", mode = { "n" }, "<cmd>Leet yank<cr>" },
    },
  }
}
