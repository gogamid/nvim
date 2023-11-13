return {
  "scalameta/nvim-metals",
  dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap" },
  ft = { "scala", "sbt" },
  keys = {
    { "<leader>cW", function() require("metals").hover_worksheet() end, desc = "Metals Worksheet", },
    { "<leader>cM", function() require("telescope").extensions.metals.commands() end, desc = "Telescope Metals Commands", },
  },
  event = "BufEnter *.worksheet.sc",
  config = function()
    local map = vim.keymap.set
    vim.opt_global.completeopt = { "menuone", "noinsert", "noselect" }
    vim.opt_global.opt_global.shortmess:remove("F")
    vim.opt_global.shortmess:append("c")

    map("n", "<leader>cc", vim.lsp.codelens.run)
    local metals_config = require("metals").bare_config()
    metals_config.settings = {
      -- useGlobalExecutable = true,
      -- metalsBinaryPath = "C:/Users/dtwj6af/scoop/apps/coursier/current/bin/metals.bat",
      showImplicitArguments = true,
      showInferredType = true,
      superMethodLensesEnabled = true,
      showImplicitConversionsAndClasses = true,
      serverProperties = {
        "-Dsbt.boot.credentials=C:/Users/dtwj6af/.sbt/.credentials",
        "-Dfile.encoding=UTF-8",
      },
      enableSemanticHighlighting = true,
      -- bloopSbtAlreadyInstalled = true,
      -- disabledMode = true,
    }

    -- *READ THIS*
    -- I *highly* recommend setting statusBarProvider to true, however if you do,
    -- you *have* to have a setting to display this in your statusline or else
    -- you'll not see any messages from metals. There is more info in the help
    -- docs about this
    metals_config.init_options.statusBarProvider = "on"

    -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
    metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- Debug settings if you're using nvim-dap
    local dap = require("dap")
    -- true if C:/Users/dtwj6af exists else false
    -- local isPersonal = vim.fn.isdirectory("C:/Users/dtwj6af") ~= 0
    local isPersonal = false

    local premiumPath = isPersonal and "file:///Users/gogamid/someip-analysis/traces/premium"
      or "file:///C:/Users/dtwj6af/code/eg112_an_reboot_analyse/local-inputs/premium"

    local mebUnecePath = isPersonal and "file:///Users/gogamid/someip-analysis/traces/meb-unece"
      or "file:///C:/Users/dtwj6af/code/eg112_an_reboot_analyse/local-inputs/meb-unece"

    local outputPath = isPersonal and "file:///Users/gogamid/someip-analysis/result/" or "file:///C:/Temp/"

    local function getArguments(trace, path)
      local arguments = {
        "-i",
        path .. "/" .. trace,
        "-o",
        outputPath,
        "-s",
        path .. "/stream-description.json",
      }
      return arguments
    end

    dap.configurations.scala = {

      {
        type = "scala",
        request = "launch",
        name = "pcap1",
        metals = {
          mainClass = "Main",
          runType = "run",
          buildTarget = "root",
          args = getArguments("tcp29791__TQ23500_LF643990_viwiSample.pcapng", premiumPath),
        },
      },
      {
        type = "scala",
        request = "launch",
        name = "pcap",
        metals = {
          mainClass = "Main",
          runType = "run",
          buildTarget = "root",
          args = getArguments("http__TQ23501_LF643990_viwiSample.pcapng", premiumPath),
        },
      },
      {
        type = "scala",
        request = "launch",
        name = "mbeuS",
        metals = {
          mainClass = "Main",
          runType = "run",
          buildTarget = "root",
          args = getArguments("LF604317_AU316-2EU-B_UNECE_IN-N6946_230517_174726_TRUE_TRACE_005.TTL", mebUnecePath),
        },
      },
      {
        type = "scala",
        request = "launch",
        name = "ppeS",
        metals = {
          mainClass = "vwg.audi.eg112.reboot.analyse.RebootAnalysis",
          runType = "run",
          -- buildTarget = "root",
          args = getArguments("LF481773_1Min-Part0.ttl", premiumPath),
        },
      },
      {
        type = "scala",
        request = "launch",
        name = "ppeL",
        metals = {
          mainClass = "Main",
          runType = "run",
          buildTarget = "root",
          args = getArguments(
            "LF578791_AU402-0EU-K_HN-DE657_017_20230322_155024_PM200_PPE_PPC_NoStby_2.9.0.ttl",
            premiumPath
          ),
        },
      },
      {
        type = "scala",
        request = "launch",
        name = "RunOrTest",
        metals = {
          runType = "runOrTestFile",
          --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
        },
      },
      {
        type = "scala",
        request = "launch",
        name = "Test Target",
        metals = {
          runType = "testTarget",
        },
      },
    }

    metals_config.on_attach = function(client, bufnr)
      local metals = require("metals")
      metals.setup_dap()
    end

    require("metals").initialize_or_attach(metals_config)
  end,
}
