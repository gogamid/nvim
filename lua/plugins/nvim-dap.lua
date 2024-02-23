return {
  {
    "mfussenegger/nvim-dap",
    optional = false,
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          vim.list_extend(opts.ensure_installed, { "java-test", "java-debug-adapter" })
        end,
      },
    },
    keys = {
      { "<F1>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<F2>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<F3>", function() require("dap").step_out() end, desc = "Step Out" },
      { "<F4>", function() require("dap").continue() end, desc = "Continue" },
      {"<leader>di", false},
      {"<leader>dO", false},
      {"<leader>do", false},
      {"<leader>dc", false}
    },
  },
}
