***REMOVED***
  {
    "mfussenegger/nvim-dap",

    dependencies = {

      -- fancy UI for the debugger
***REMOVED***
        "rcarriga/nvim-dap-ui",
      -- stylua: ignore
    ***REMOVED***
  ***REMOVED*** "<leader>du", function() require("dapui").toggle({ ***REMOVED***) end, desc = "Dap UI" ***REMOVED***,
  ***REMOVED*** "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"***REMOVED*** ***REMOVED***,
    ***REMOVED***
        opts = {***REMOVED***,
        config = function(_, opts)
      ***REMOVED***
          local dapui = require("dapui")
          dapui.setup(opts)
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open({***REMOVED***)
      ***REMOVED***
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close({***REMOVED***)
      ***REMOVED***
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close({***REMOVED***)
      ***REMOVED***
    ***REMOVED***,
    ***REMOVED***

      -- virtual text for the debugger
***REMOVED***
        "theHamsta/nvim-dap-virtual-text",
        opts = {***REMOVED***,
    ***REMOVED***

      -- which key integration
***REMOVED***
        "folke/which-key.nvim",
        optional = true,
        opts = {
          defaults = {
            ["<leader>d"] = { name = "+debug" ***REMOVED***,
            ["<leader>da"] = { name = "+adapters" ***REMOVED***,
        ***REMOVED***
      ***REMOVED***
    ***REMOVED***

      -- mason.nvim integration
***REMOVED***
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "mason.nvim",
        cmd = { "DapInstall", "DapUninstall" ***REMOVED***,
        opts = {
          -- Makes a best effort to setup the various debuggers with
          -- reasonable debug configurations
          automatic_installation = true,

          -- You can provide additional configuration to the handlers,
          -- see mason-nvim-dap README for more information
          handlers = {***REMOVED***,

          -- You'll need to check that you have the required things installed
          -- online, please don't ask me how to install them :)
          ensure_installed = {
            -- Update this to ensure that you have the debuggers for the langs you want
        ***REMOVED***
      ***REMOVED***
    ***REMOVED***
  ***REMOVED***

    -- stylua: ignore
  ***REMOVED***
***REMOVED*** "<F1>", function() require("dap").step_into() end, desc = "Step Into" ***REMOVED***,
***REMOVED*** "<F2>", function() require("dap").step_over() end, desc = "Step Over" ***REMOVED***,
***REMOVED*** "<F3>", function() require("dap").step_out() end, desc = "Step Out" ***REMOVED***,
***REMOVED*** "<F4>", function() require("dap").continue() end, desc = "Continue" ***REMOVED***,
      -- { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" ***REMOVED***,
      -- { "<leader>dc", function() require("dap").continue() end, desc = "Continue" ***REMOVED***,
      -- { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" ***REMOVED***,
      -- { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" ***REMOVED***,
***REMOVED*** "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" ***REMOVED***,
***REMOVED*** "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" ***REMOVED***,
***REMOVED*** "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" ***REMOVED***,
***REMOVED*** "<leader>dg", function() require("dap").goto_() end, desc = "Go to line (no execute)" ***REMOVED***,
***REMOVED*** "<leader>dj", function() require("dap").down() end, desc = "Down" ***REMOVED***,
***REMOVED*** "<leader>dk", function() require("dap").up() end, desc = "Up" ***REMOVED***,
***REMOVED*** "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" ***REMOVED***,
***REMOVED*** "<leader>dp", function() require("dap").pause() end, desc = "Pause" ***REMOVED***,
***REMOVED*** "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" ***REMOVED***,
***REMOVED*** "<leader>ds", function() require("dap").session() end, desc = "Session" ***REMOVED***,
***REMOVED*** "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" ***REMOVED***,
***REMOVED*** "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" ***REMOVED***,
  ***REMOVED***

  ***REMOVED***
      local Config = require("lazyvim.config")
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" ***REMOVED***)

      for name, sign in pairs(Config.icons.dap) do
        sign = type(sign) == "table" and sign or { sign ***REMOVED***
        vim.fn.sign_define(
          "Dap" .. name,
    ***REMOVED*** text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] ***REMOVED***
        )
  ***REMOVED***
***REMOVED***,
***REMOVED***
***REMOVED***
