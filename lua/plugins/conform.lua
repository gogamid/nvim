return {
  {
    "stevearc/conform.nvim",
    opts = {
      default_format_opts = {
        lsp_format = "fallback",
        -- async = true,
        timeout_ms = 1000,
      },
      formatters_by_ft = {
        proto = { "buf" },
        go = {}, -- gopls runs them
        query = { "format-queries" },
        http = { "kulala-fmt" },
        xml = { "xmlformatter" },
      },
      formatters = {},
    },
  },
}
