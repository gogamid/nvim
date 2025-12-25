local leet_arg = "leetcode.nvim"
return {
  "kawre/leetcode.nvim",
  enabled = true,
  lazy = leet_arg ~= vim.fn.argv()[1],
  cmd = "Leet",
  opts = {
    arg = leet_arg,
    lang = "golang",
    injector = {
      ["cpp"] = {
        before = { "#include <bits/stdc++.h>", "using namespace std;" },
        after = "int main() {}",
      },
      ["java"] = {
        before = "import java.util.*;",
      },
      ["golang"] = {
        before = "package main",
      },
    },
    picker = { provider = "snacks-picker" },
  },
  build = ":TSUpdate html",
  dependencies = {
    "folke/snacks.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { ft = leet_arg, "<leader>lq", ":Leet tabs<cr>", desc = "Leetcode Tabs" },
    { ft = leet_arg, "<leader>lm", ":Leet menu<cr>", desc = "Leetcode Menu" },
    { ft = leet_arg, "<leader>lc", ":Leet console<cr>", desc = "Leetcode Console" },
    { ft = leet_arg, "<leader>li", ":Leet info<cr>", desc = "Leetcode Info" },
    { ft = leet_arg, "<leader>ll", ":Leet lang<cr>", desc = "Leetcode Lang" },
    { ft = leet_arg, "<leader>ld", ":Leet desc<cr>", desc = "Leetcode Desc" },
    { ft = leet_arg, "<leader>lr", ":Leet run<cr>", desc = "Leetcode Run" },
    { ft = leet_arg, "<leader>ls", ":Leet submit<cr>", desc = "Leetcode Submit" },
    { ft = leet_arg, "<leader>ly", ":Leet yank<cr>", desc = "Leetcode Yank" },
    { ft = leet_arg, "<leader>lp", ":Leet list<cr>", desc = "Leetcode List" },
    { ft = leet_arg, "<leader>lx", ":Leet reset<cr>", desc = "Leetcode Reset" },
    { ft = leet_arg, "<leader>lh", ":Leet last_submit<cr>", desc = "Leetcode Last Submit" },
  },
}
