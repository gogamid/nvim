local leet_arg = "leetcode.nvim"
return {
  "kawre/leetcode.nvim",
  enabled = false,
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
    { "<leader>lq", ":Leet tabs<cr>", desc = "Leetcode Tabs" },
    { "<leader>lm", ":Leet menu<cr>", desc = "Leetcode Menu" },
    { "<leader>lc", ":Leet console<cr>", desc = "Leetcode Console" },
    { "<leader>li", ":Leet info<cr>", desc = "Leetcode Info" },
    { "<leader>ll", ":Leet lang<cr>", desc = "Leetcode Lang" },
    { "<leader>ld", ":Leet desc<cr>", desc = "Leetcode Desc" },
    { "<leader>lr", ":Leet run<cr>", desc = "Leetcode Run" },
    { "<leader>ls", ":Leet submit<cr>", desc = "Leetcode Submit" },
    { "<leader>ly", ":Leet yank<cr>", desc = "Leetcode Yank" },
    { "<leader>lp", ":Leet list<cr>", desc = "Leetcode List" },
    { "<leader>lx", ":Leet reset<cr>", desc = "Leetcode Reset" },
    { "<leader>lh", ":Leet last_submit<cr>", desc = "Leetcode Last Submit" },
  },
}
