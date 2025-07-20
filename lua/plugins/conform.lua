return {
  {
    "stevearc/conform.nvim",
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "goimports", "gofumpt" } },
      },
    },
    opts = {
      default_format_opts = {
        lsp_format = "never",
        async = true,
        timeout_ms = 100,
      },
      format_after_save = {
        lsp_format = "never",
      },
      formatters_by_ft = {
        proto = { "buf" },
        go = { "goimports", "gofumpt" },
        lua = { "stylua" },
        toml = { "taplo" },
      },
      formatters = {},
    },
  },
}
