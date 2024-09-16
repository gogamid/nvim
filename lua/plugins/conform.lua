return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        proto = { "buf" },
      },
      formatters = {
        goimports = {
          prepend_args = { "-local", "dev.azure.com/schwarzit/lidl.wawi-core" },
        },
      },
    },
  },
}