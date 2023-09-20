***REMOVED***
  {
    "mfussenegger/nvim-jdtls",
    dependencies = { "folke/which-key.nvim" ***REMOVED***,
    ft = java_filetypes,
    opts = function()
      ***REMOVED***
        -- How to find the root dir for a given filename. The default comes from
        -- lspconfig which provides a function specifically for java projects.
        root_dir = require("lspconfig.server_configurations.jdtls").default_config.root_dir,

        -- How to find the project name for a given root dir.
        project_name = function(root_dir)
          return root_dir and vim.fs.basename(root_dir)
    ***REMOVED***,

        -- Where are the config and workspace dirs for a project?
        jdtls_config_dir = function(project_name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/config"
    ***REMOVED***,
        jdtls_workspace_dir = function(project_name)
          return vim.fn.stdpath("cache") .. "/jdtls/" .. project_name .. "/workspace"
    ***REMOVED***,

        -- How to run jdtls. This can be overridden to a full java command-line
        -- if the Python wrapper script doesn't suffice.
        cmd = { "jdtls" ***REMOVED***,
        full_cmd = function(opts)
          local fname = vim.api.nvim_buf_get_name(0)
          local root_dir = opts.root_dir(fname)
          local project_name = opts.project_name(root_dir)
          local cmd = vim.deepcopy(opts.cmd)
          if project_name then
            vim.list_extend(cmd, {
              "-configuration",
              opts.jdtls_config_dir(project_name),
              "-data",
              opts.jdtls_workspace_dir(project_name),
        ***REMOVED***)
      ***REMOVED***
          return cmd
    ***REMOVED***,

        -- These depend on nvim-dap, but can additionally be disabled by setting false here.
        dap = { hotcodereplace = "auto", config_overrides = {***REMOVED*** ***REMOVED***,
        test = true,
  ***REMOVED***
***REMOVED***,
  ***REMOVED***
      local opts = Util.opts("nvim-jdtls") or {***REMOVED***

      -- Find the extra bundles that should be passed on the jdtls command-line
      -- if nvim-dap is enabled with java debug/test.
      local mason_registry = require("mason-registry")
      local bundles = {***REMOVED*** ---@type string[]
      if opts.dap and Util.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
        local java_dbg_pkg = mason_registry.get_package("java-debug-adapter")
        local java_dbg_path = java_dbg_pkg:get_install_path()
        local jar_patterns = {
          java_dbg_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar",
    ***REMOVED***
        -- java-test also depends on java-debug-adapter.
        if opts.test and mason_registry.is_installed("java-test") then
          local java_test_pkg = mason_registry.get_package("java-test")
          local java_test_path = java_test_pkg:get_install_path()
          vim.list_extend(jar_patterns, {
            java_test_path .. "/extension/server/*.jar",
      ***REMOVED***)
    ***REMOVED***
        for _, jar_pattern in ipairs(jar_patterns) do
          for _, bundle in ipairs(vim.split(vim.fn.glob(jar_pattern), "\n")) do
            table.insert(bundles, bundle)
      ***REMOVED***
    ***REMOVED***
  ***REMOVED***

      local function attach_jdtls()
        local fname = vim.api.nvim_buf_get_name(0)

        -- Configuration can be augmented and overridden by opts.jdtls
        local config = extend_or_override({
          cmd = opts.full_cmd(opts),
          root_dir = opts.root_dir(fname),
          init_options = {
            bundles = bundles,
        ***REMOVED***
          -- enable CMP capabilities
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
      ***REMOVED*** opts.jdtls)

        -- Existing server will be reused if the root_dir matches.
        require("jdtls").start_or_attach(config)
        -- not need to require("jdtls.setup").add_commands(), start automatically adds commands
  ***REMOVED***

      -- Attach the jdtls for each java buffer. HOWEVER, this plugin loads
      -- depending on filetype, so this autocmd doesn't run for the first file.
      -- For that, we call directly below.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = java_filetypes,
        callback = attach_jdtls,
  ***REMOVED***)

      -- Setup keymap and dap after the lsp is fully attached.
      -- https://github.com/mfussenegger/nvim-jdtls#nvim-dap-configuration
      -- https://neovim.io/doc/user/lsp.html#LspAttach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "jdtls" then
            local wk = require("which-key")
            wk.register({
              ["<leader>cx"] = { name = "+extract" ***REMOVED***,
              ["<leader>cxv"] = { require("jdtls").extract_variable_all, "Extract Variable" ***REMOVED***,
              ["<leader>cxc"] = { require("jdtls").extract_constant, "Extract Constant" ***REMOVED***,
              ["gs"] = { require("jdtls").super_implementation, "Goto Super" ***REMOVED***,
              ["gS"] = { require("jdtls.tests").goto_subjects, "Goto Subjects" ***REMOVED***,
              ["<leader>co"] = { require("jdtls").organize_imports, "Organize Imports" ***REMOVED***,
          ***REMOVED*** { mode = "n", buffer = args.buf ***REMOVED***)
            wk.register({
              ["<leader>c"] = { name = "+code" ***REMOVED***,
              ["<leader>cx"] = { name = "+extract" ***REMOVED***,
              ["<leader>cxm"] = {
                [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
                "Extract Method",
            ***REMOVED***
              ["<leader>cxv"] = {
                [[<ESC><CMD>lua require('jdtls').extract_variable_all(true)<CR>]],
                "Extract Variable",
            ***REMOVED***
              ["<leader>cxc"] = {
                [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
                "Extract Constant",
            ***REMOVED***
          ***REMOVED*** { mode = "v", buffer = args.buf ***REMOVED***)

            if opts.dap and Util.has("nvim-dap") and mason_registry.is_installed("java-debug-adapter") then
              -- custom init for Java debugger
              require("jdtls").setup_dap(opts.dap)
              require("jdtls.dap").setup_dap_main_class_configs()

              -- Java Test require Java debugger to work
              if opts.test and mason_registry.is_installed("java-test") then
                -- custom keymaps for Java test runner (not yet compatible with neotest)
                wk.register({
                  ["<leader>t"] = { name = "+test" ***REMOVED***,
                  ["<leader>tt"] = { require("jdtls.dap").test_class, "Run All Test" ***REMOVED***,
                  ["<leader>tr"] = { require("jdtls.dap").test_nearest_method, "Run Nearest Test" ***REMOVED***,
                  ["<leader>tT"] = { require("jdtls.dap").pick_test, "Run Test" ***REMOVED***,
              ***REMOVED*** { mode = "n", buffer = args.buf ***REMOVED***)
          ***REMOVED***
        ***REMOVED***

            -- User can set additional keymaps in opts.on_attach
            if opts.on_attach then
              opts.on_attach(args)
        ***REMOVED***
      ***REMOVED***
    ***REMOVED***,
  ***REMOVED***)

      -- Avoid race condition by calling attach the first time, since the autocmd won't fire.
      attach_jdtls()
***REMOVED***,
***REMOVED***
***REMOVED***
