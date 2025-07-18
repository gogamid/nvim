return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  build = "make",

  opts = {
    provider = "copilot",
    providers = {
      ollama = {
        endpoint = "http://localhost:11434",
        model = "gemma3n:e4b",
      },
    },

    web_search_engine = {
      provider = "tavily", -- tavily, serpapi, google, kagi, brave, or searxng
      proxy = nil, -- proxy support, e.g., http://127.0.0.1:7890
    },
    behaviour = {
      enable_fastapply = true, -- Enable Fast Apply feature
      auto_suggestions = false,
    },

    input = {
      provider = "snacks", -- "native" | "dressing" | "snacks"
    },
    selector = {
      provider = "snacks",
    },

    windows = {},
    custom_tools = {
      {
        name = "run_go_tests", -- Unique name for the tool
        description = "Run Go unit tests and return results", -- Description shown to AI
        command = "go test -v ./...", -- Shell command to execute
        param = { -- Input parameters (optional)
          type = "table",
          fields = {
            {
              name = "target",
              description = "Package or directory to test (e.g. './pkg/...' or './internal/pkg')",
              type = "string",
              optional = true,
            },
          },
        },
        returns = { -- Expected return values
          {
            name = "result",
            description = "Result of the fetch",
            type = "string",
          },
          {
            name = "error",
            description = "Error message if the fetch was not successful",
            type = "string",
            optional = true,
          },
        },
        func = function(params, on_log, on_complete) -- Custom function to execute
          local target = params.target or "./..."
          return vim.fn.system(string.format("go test -v %s", target))
        end,
      },
    },
  },
}
