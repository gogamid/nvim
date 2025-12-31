return {
  "folke/which-key.nvim",
  event = "VimEnter",
  opts = {
    preset = "helix",
    spec = {
      { "<leader>a", "", desc = "ai", mode = { "n", "v" } },
      { "<leader>c", "", desc = "code", mode = { "n", "v" } },
      { "<leader>f", "", desc = "find", mode = { "n", "v" } },
      { "<leader>g", "", desc = "git", mode = { "n", "v" } },
      { "<leader>o", "", desc = "obsidian", mode = { "n", "v" }, icon = "📓" },
      { "<leader>s", "", desc = "search", mode = { "n", "v" } },
      { "<leader>q", "", desc = "session", mode = { "n", "v" } },
      { "<leader>r", "", desc = "refactor(todo)", mode = { "n", "v" } },
      { "<leader>t", "", desc = "task(todo)", mode = { "n", "v" } },
      { "<leader>u", "", desc = "toggles", mode = { "n", "v" } },
      { "<leader>v", "", desc = "visual(todo)", mode = { "n", "v" } },
      { "<leader>w", "", desc = "window(todo)", mode = { "n", "v" } },
      { "<leader>b", "", desc = "buffer(todo)", mode = { "n", "v" } },
      { "<leader>h", "", desc = "hunks", mode = { "n", "v" } },
    },
  },
}
