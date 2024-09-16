return {
  {
    "ramilito/kubectl.nvim",
    config = function()
      require("kubectl").setup()
    end,
    keys = {
      { "<leader>k", "", mode = "n", desc = "+kubectl" },
      { "<leader>kk", ':lua require("kubectl").toggle()<cr>', mode = "n", desc = "Open Kubectl" },
      {
        "<leader>kt",
        function()
          require("kubectl").toggle()
          vim.cmd("Kubectx intwawiplatform-tst-aks")
        end,
        mode = "n",
        desc = "Open kubectl test",
      },
      {
        "<leader>kd",
        function()
          require("kubectl").toggle()
          vim.cmd("Kubectx intwawiplatform-dev-aks")
        end,
        mode = "n",
        desc = "Open kubectl dev",
      },
    },
  },
}
