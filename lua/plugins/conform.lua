return {
  {
    "stevearc/conform.nvim",
    opts = {
      default_format_opts = {
        lsp_format = "fallback",
        -- async = true,
        timeout_ms = 500,
      },
      formatters_by_ft = {
        proto = { "buf" },
      },
      formatters = {
        goimports = {
          prepend_args = { "-local", "dev.azure.com/schwarzit/lidl.wawi-core/" },
        },
        formatters_by_ft = {
          go = function()
            return { "goimports", "gofumpt" } -- removing goimports if needed
          end,
        },
      },
    },
  },
}
