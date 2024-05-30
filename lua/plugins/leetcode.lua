local leet_arg = "leetcode.nvim"
return {
  {
    "kawre/leetcode.nvim",
    lazy = leet_arg ~= vim.fn.argv()[1],
    opts = {
      arg = leet_arg,
      lang = "java",
      injector = { ---@type table<lc.lang, lc.inject>
        ["cpp"] = {
          before = { "#include <bits/stdc++.h>", "using namespace std;" },
          after = "int main() {}",
        },
        ["java"] = {
          before = "import java.util.*;",
        },
      },
    },
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
      { "<leader>lq", mode = { "n" }, ":Leet tabs<cr>" },
      { "<leader>lm", mode = { "n" }, ":Leet menu<cr>" },
      { "<leader>lc", mode = { "n" }, ":Leet console<cr>" },
      { "<leader>li", mode = { "n" }, ":Leet info<cr>" },
      { "<leader>ll", mode = { "n" }, ":Leet lang<cr>" },
      { "<leader>ld", mode = { "n" }, ":Leet desc<cr>" },
      { "<leader>lr", mode = { "n" }, ":Leet run<cr>" },
      { "<leader>ls", mode = { "n" }, ":Leet submit<cr>" },
      { "<leader>ly", mode = { "n" }, ":Leet yank<cr>" },
      { "<leader>lp", mode = { "n" }, ":Leet list<cr>" },
      { "<leader>le", mode = { "n" }, ":Leet list difficulty=easy<cr>" },
      { "<leader>lx", mode = { "n" }, ":Leet reset<cr>" },
      { "<leader>lh", mode = { "n" }, ":Leet last_submit<cr>" },
    },
  },
}
