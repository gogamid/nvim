return {
  {
    "mfussenegger/nvim-dap",
     -- stylua: ignore
    keys = {
      -- disable and remap
--DapNew
-- DapEval
-- DapInstall
-- DapShowLog
-- DapStepOut
-- DapContinue
-- DapStepInto
-- DapStepOver
-- DapTerminate
-- DapUninstall
-- DapToggleRepl
-- DapSetLogLevel
-- DapRestartFrame
-- DapLoadLaunchJSON
-- DapToggleBreakpoint
-- DapVirtualTextEnable
-- DapVirtualTextToggle
-- DapVirtualTextDisable
-- DapVirtualTextForceRefresh
-- DashboardUpdateFooter
-- DoMatchParen
-- UpdateRemotePlugins
-- IBLDisableScope
      { "<leader>di", false },
      { "<leader>dO", false },
      { "<leader>do", false },
      { "<leader>dc", false },
      { "<F1>",":DapStepInto<cr>" , desc = "Step Into", },
      {"<F2>", ":DapStepOver<cr>", desc = "Step Over",},
      {"<F3>", ":DapStepOut<cr>", desc = "Step Out",},
      {"<F4>", ":DapContinue<cr>", desc = "Continue",},
    },
  },
}
