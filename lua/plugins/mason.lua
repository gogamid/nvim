return {
  {
    "mason-org/mason.nvim",
    opts = {
      log_level = vim.log.levels.DEBUG,
    },
    keys = {
      { "<leader>M", "<cmd>Mason<cr>", desc = "Mason Menu" },
    },
  },
}
