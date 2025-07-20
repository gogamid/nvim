return {
  "yetone/avante.nvim",
  enabled = true,
  event = "VeryLazy",
  lazy = false,
  build = "make",

  keys = {
    { "<leader>as", false },
  },
  opts = {
    provider = "copilot",
    providers = {
      ollama = {
        endpoint = "http://localhost:11434",
        model = "gemma3n:e4b",
      },
      copilot = {
        model = "gemini-2.5-pro",
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
  },
}
