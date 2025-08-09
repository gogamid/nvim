return {
  "stevearc/conform.nvim",
  opts = {
    default_format_opts = {
      lsp_format = "never",
      async = true,
      timeout_ms = 100,
    },
    format_after_save = function()
      if vim.g.autoformat then
        return nil
      else
        return { lsp_format = "never" }
      end
    end,
    formatters_by_ft = {
      proto = { "buf" },
      go = { "goimports", "gofumpt" },
      lua = { "stylua" },
      toml = { "taplo" },
      sh = { "shfmt" },
      markdown = { "prettier" },
      xml = { "xmlformatter" },
    },
    formatters = {},
  },
  config = function(_, opts)
    require("conform").setup(opts)

    Snacks.toggle({
      name = "Autoformat",
      get = function()
        return not vim.g.autoformat
      end,
      set = function(state)
        vim.g.autoformat = not state
      end,
    }):map("<leader>uf")
  end,
}
