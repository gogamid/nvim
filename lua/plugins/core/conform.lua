return {
  {
    "stevearc/conform.nvim",
    lazy = false,
    dependencies = {
      "folke/snacks.nvim", -- toggles
    },
    opts = {
      default_format_opts = {
        lsp_format = "fallback",
        async = true,
        timeout_ms = 1000,
      },
      formatters = {
        cformatter42 = {
          enabled = vim.fn.executable("c_formatter_42"),
          command = "c_formatter_42",
        },
      },
      formatters_by_ft = {
        c = { "cformatter42" },
        typst = { "typstyle" },
        lua = { "stylua" },
        proto = { "buf" },
        go = { "gofumpt", "goimports", lsp_format = "last" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        json = { "prettier" },
        vue = { "prettier", lsp_format = "first" },
        typescript = { "prettier", lsp_format = "first" },
        javascript = { "prettier", lsp_format = "first" },
        toml = { "taplo" },
        sh = { "shfmt" },
        xml = { "xmlformatter" },
        terraform = { "terraform" },
        hcl = { "terragrunt" },
        sql = { "sql_formatter" },
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
      {
        "<leader>cf",
        function()
          require("conform").format()
        end,
        mode = { "n", "x" },
        desc = "Format",
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

      local always_disabled_fts = { "sql" }

      vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function(event)
          if vim.tbl_contains(always_disabled_fts, vim.bo[event.buf].filetype) then
            return
          end
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
  },
}
