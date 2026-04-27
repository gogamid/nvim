return {
  "nanotee/zoxide.vim",
  config = function()
    vim.g.zoxide_hook = "pwd"
    vim.g.zoxide_use_select = 1
  end,
  keys = {
    { "<leader>fz", "<cmd>Zi<cr>", desc = "Zoxide change cwd" },
  },
}
