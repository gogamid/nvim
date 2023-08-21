***REMOVED***
  {
    "mfussenegger/nvim-dap-python",
  -- stylua: ignore
***REMOVED***
    { "<leader>dPt", function() require('dap-python').test_method() end, desc = "Debug Method" ***REMOVED***,
    { "<leader>dPc", function() require('dap-python').test_class() end, desc = "Debug Class" ***REMOVED***,
***REMOVED***
  ***REMOVED***
      -- local path = require("mason-registry").get_package("debugpy"):get_install_path()
      require("dap-python").setup("/Users/gogamid/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
***REMOVED***,
***REMOVED***
***REMOVED***
