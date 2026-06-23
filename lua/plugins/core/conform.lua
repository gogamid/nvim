local jsFormatter = { "prettier", lsp_format = "never" }

local function organize_go_imports(bufnr)
  local client = vim.lsp.get_clients({ name = "gopls", bufnr = bufnr })[1]
  if not client then
    return
  end

  local params = vim.lsp.util.make_range_params(0, client.offset_encoding or "utf-8")
  params.context = { only = { "source.organizeImports" }, diagnostics = {} }

  local result = client:request_sync("textDocument/codeAction", params, 3000, bufnr)
  if not result or result.err or not result.result or vim.tbl_isempty(result.result) then
    return
  end

  for _, action in ipairs(result.result) do
    if action.kind == "source.organizeImports" then
      vim.notify("Organizing imports...")
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding or "utf-8")
      end
      if action.command then
        client:request_sync("workspace/executeCommand", action.command, 3000, bufnr)
      end
      return
    end
  end
end

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
        dart = { "dart_format" },
        typst = { "typstyle" },
        lua = { "stylua" },
        proto = { "buf" },
        go = { "gofumpt", "goimports", lsp_format = "last" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        json = { "prettier" },
        vue = jsFormatter,
        typescript = jsFormatter,
        javascript = jsFormatter,
        toml = { "taplo" },
        sh = { "shfmt" },
        xml = { "xmlformatter" },
        terraform = { "terraform_fmt" },
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
          local filetype = vim.bo[event.buf].filetype
          if vim.tbl_contains(always_disabled_fts, filetype) then
            return
          end
          if autoformat_enabled(event.buf) then
            require("conform").format({ bufnr = event.buf, async = false, timeout_ms = 3000 })
            -- if filetype == "go" then
            --   organize_go_imports(event.buf)
            -- end
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
