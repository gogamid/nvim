return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = {lsp_format = "prefer"},
      proto = {"buf"},
      go = {"goimports", "gofumpt"},
      yaml = {"prettier"},
      markdown = {"prettier"},
      json = {"prettier"},
      vue = {"prettier", lsp_format = "last"},
      typescript = {"prettier", lsp_format = "last"},
      javascript = {"prettier", lsp_format = "last"},
      toml = {"taplo"},
      sh = {"shfmt"},
      xml = {"xmlformatter"},
    },
    default_format_opts = {
      lsp_format = "fallback",
      async = true,
      timeout_ms = 100,
    },
    format_after_save = function()
      if vim.g.autoformat then
        return nil
      else
        return {}
      end
    end,
  },
  config = function(_, opts)
    require("conform").setup(opts)

    Snacks.toggle({
      name = "Autoformat",
      get = function() return not vim.g.autoformat end,
      set = function(state) vim.g.autoformat = not state end,
    }):map("<leader>uf")
  end,
}
