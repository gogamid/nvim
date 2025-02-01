return {

  {
    "nvim-neotest/neotest",
    -- stylua: ignore
    keys = {
      {"<leader>tq", "", desc = "+test"},

      { "<leader>tt", false},
      { "<leader>tT", false},
      { "<leader>tr", false},
      { "<leader>tl", false},
      { "<leader>ts", false},
      { "<leader>to", false},
      { "<leader>tO", false},
      { "<leader>tS", false},
      { "<leader>tw", false},

      { "<leader>tqt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File (Neotest)" },
      { "<leader>tqT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run All Test Files (Neotest)" },
      { "<leader>tqr", function() require("neotest").run.run() end, desc = "Run Nearest (Neotest)" },
      { "<leader>tql", function() require("neotest").run.run_last() end, desc = "Run Last (Neotest)" },
      { "<leader>tqs", function() require("neotest").summary.toggle() end, desc = "Toggle Summary (Neotest)" },
      { "<leader>tqo", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output (Neotest)" },
      { "<leader>tqO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel (Neotest)" },
      { "<leader>tqS", function() require("neotest").run.stop() end, desc = "Stop (Neotest)" },
      { "<leader>tqw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle Watch (Neotest)" },
    },
  },
}
