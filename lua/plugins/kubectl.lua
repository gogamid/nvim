return {
  {
    "ramilito/kubectl.nvim",
    keys = {
      { "<leader>kk", ':lua require("kubectl").toggle()<cr>', mode = "n", desc = "Open Kubectl" },
    },
    config = function(_, opts)
      require("kubectl").setup(opts)
    end,
  },
}
