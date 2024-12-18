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
        go = { "gofumpt", "goimports" },
        sql = { "sqlfluff", "pg_format", "sleek" },
        query = { "format-queries" },
      },
      formatters = {
        goimports = {
          prepend_args = { "-local", "dev.azure.com/schwarzit/lidl.wawi-core/" },
        },
        sqlfluff = {
          command = "sqlfluff",
          args = {
            "format",
            "--dialect=ansi",
            "--nocolor",
            "--disable-progress-bar",
            "-",
          },
        },
        -- doesn't support all
        sleek = {
          command = "sleek",
          args = { "--indent-spaces", "4", "--uppercase", "--lines-between-queries", "2" },
          stdin = true,
        },
        pg_format = {
          command = "pg_format",
          args = {
            "-p",
            "-C",
            "-",
          },
          stdin = true,
        },
        --good but only lower case
        -- sqlfmt = {
        --   command = "sqlfmt",
        --   args = {
        --     "--fast",
        --     "--quiet",
        --     "--no-color",
        --     "--no-progressbar",
        --     "-",
        --   },
        --   stdin = true,
        -- },
      },
      init = function()
        -- local autocmd = vim.api.nvim_create_autocmd
        -- local augroup = vim.api.nvim_create_augroup
        --
        -- -- Didn't manage to add formatting specified with a lua function
        -- -- to conform, so do it manually.
        -- autocmd("BufWritePre", {
        --   pattern = {
        --     "query",
        --     "*scm",
        --   },
        --   group = augroup("scm", { clear = true }),
        --   callback = require("custom/format_queries").format,
        -- })
      end,
    },
  },
}
