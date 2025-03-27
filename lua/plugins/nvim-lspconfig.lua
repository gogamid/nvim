local function organize_imports_if_available()
  local params = vim.lsp.util.make_range_params(0, "utf-8")
  vim.lsp.buf_request(0, "textDocument/codeAction", params, function(err, result, _)
    if err or not result or vim.tbl_isempty(result) then
      return
    end
    for _, action in pairs(result) do
      if action.kind == "source.organizeImports" then
        if action.command then
          LazyVim.lsp.action["source.organizeImports"]()
        elseif action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
        end
        return
      end
    end
  end)
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      format = {
        timeout_ms = 500,
      },
      inlay_hints = { enabled = false },
      servers = {
        eslint = {
          on_attach = function(_, bufnr)
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              command = "EslintFixAll",
            })
          end,
        },
        -- make sure the proto server is insalled with default config
        buf_ls = {},
        gopls = {
          settings = {
            gopls = {
              buildFlags = { "-tags=manual_test" },
              ["local"] = os.getenv("GO_LOCAL_PKG"),
              analyses = {
                shadow = true,
                unusedvariable = true,
              },
              hints = {
                assignVariableTypes = false,
                compositeLiteralFields = false,
                compositeLiteralTypes = false,
                constantValues = true,
                functionTypeParameters = false,
                parameterNames = false,
                rangeVariableTypes = false,
              },
            },
          },
          on_attach = function(_, bufnr)
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function(_)
                organize_imports_if_available()
              end,
            })
          end,
          --reuse gopls server,  but problematic
          -- cmd = { "gopls", "-remote=auto", "-remote.listen.timeout", "2m" },
        },
        -- for go linting of extra space after for loop, combining same type method params etc
        golangci_lint_ls = {
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "service.yaml", --run it for each microservice not whole monorepo
              ".golangci.yml",
              ".golangci.yaml",
              ".golangci.toml",
              ".golangci.json",
              "go.work",
              "go.mod",
              ".git"
            )(fname)
          end,
        },
        -- removed proto from here
        clangd = {
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        },
        sqls = {},
      },
      setup = {},
    },
  },
}
