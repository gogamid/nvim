local dap = require("dap")

return {
  {
    "mfussenegger/nvim-dap",
     -- stylua: ignore
    keys = {
      -- disable and remap
      { "<leader>di", false },
      { "<leader>dO", false },
      { "<leader>do", false },
      { "<leader>dc", false },
      { "<F1>", function() dap.step_into() end, desc = "Step Into", },
      { "<F2>", function() dap.step_over() end, desc = "Step Over", },
      { "<F3>", function() dap.step_out() end, desc = "Step Out", },
      { "<F4>", function() dap.continue() end, desc = "Continue", },
    },
  },
}
