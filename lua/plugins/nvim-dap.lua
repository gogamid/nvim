return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      -- disable and remap
      { "<leader>di", false },
      { "<leader>dO", false },
      { "<leader>do", false },
      { "<leader>dc", false },
      { "<F1>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<F2>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<F3>", function() require("dap").step_out() end, desc = "Step Out" },
      { "<F4>", function() require("dap").continue() end, desc = "Continue" },
    },
  },
}
