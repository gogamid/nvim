return {
  "stevearc/conform.nvim",
  opts = {
    default_format_opts = {
      lsp_format = "fallback",
      async = true,
      timeout_ms = 1000,
    },
    formatters = {
      csqlfmt = {
        command = "sql-formatter",
        enabled = vim.fn.executable("sql-formatter"),
        args = { "--language", "plsql" },
      },
      terraform = {
        command = "terraform",
        enabled = vim.fn.executable("terraform"),
        args = { "fmt", "-no-color", "-" },
      },
      terragrunt = {
        command = "terragrunt",
        enabled = vim.fn.executable("terragrunt"),
        args = { "hclfmt", "-no-color", "-" },
      },
    },
    formatters_by_ft = {
      typst = { "typstyle" },
      lua = { "stylua" },
      proto = { "buf" },
      go = { "goimports", "gofumpt" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      json = { "prettier" },
      vue = { lsp_format = "last" },
      typescript = { lsp_format = "last" },
      javascript = { lsp_format = "last" },
      toml = { "taplo" },
      sh = { "shfmt" },
      xml = { "xmlformatter" },
      terraform = { "terraform" },
      hcl = { "terragrunt" },
    },
  },
  keys = {
    {
      "<leader>cF",
      function()
        require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
      end,
      mode = { "n", "x" },
      desc = "Format Injected Langs",
    },
  },
  config = function(_, opts)
    require("conform").setup(opts)

    local function autoformat_enabled(buf)
      buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
      local gaf = vim.g.autoformat
      local baf = vim.b[buf].autoformat

      -- If the buffer has a local value, use that
      if baf ~= nil then
        return baf
      end

      -- Otherwise use the global value if set, or true by default
      return gaf == nil or gaf
    end

    vim.api.nvim_create_autocmd("BufWritePre", {
      callback = function(event)
        if autoformat_enabled(event.buf) then
          require("conform").format({ bufnr = event.buf })
        end
      end,
    })

    Snacks.toggle({
      name = "Autoformat Buffer",
      get = function()
        return autoformat_enabled()
      end,
      set = function(state)
        vim.b.autoformat = state
      end,
    }):map("<leader>uf")

    Snacks.toggle({
      name = "Autoformat Global",
      get = function()
        return vim.g.autoformat == nil or vim.g.autoformat
      end,
      set = function(state)
        vim.g.autoformat = state
      end,
    }):map("<leader>uF")
  end,
}
