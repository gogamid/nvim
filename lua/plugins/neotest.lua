return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "fredrikaverpil/neotest-golang",
    },
    opts = {
      adapters = {
        ["neotest-golang"] = {
          -- go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
          dap_go_enabled = false,
        },
      },
    },
    config = function(_, opts)
      -- opts.consumers = { overseer = require("neotest.consumers.overseer") }
      -- opts.overseer = { enabled = true, force_default = true }
      require("neotest").setup(opts)
    end,
    keys = {
      {
        "<leader>tn",
        function()
          require("neotest").run.run()
        end,
        desc = "Run Nearest (Neotest)",
      },
    },
  },
}
