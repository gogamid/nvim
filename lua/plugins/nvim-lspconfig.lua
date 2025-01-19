local function organize_imports_if_available()
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { "source.organizeImports" } }

  vim.lsp.buf_request(0, "textDocument/codeAction", params, function(err, result, ctx, config)
    if err then
      -- print("Error fetching code actions: " .. err.message)
      return
    end

    if not result or vim.tbl_isempty(result) then
      -- print("No organize imports action available")
      return
    end

    for _, action in pairs(result) do
      if action.kind == "source.organizeImports" then
        if action.command then
          vim.lsp.buf.execute_command(action.command)
          print("Organized imports")
        elseif action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
          print("Applied workspace edit for organizing imports")
        else
          -- print("No command or edit available for organizing imports")
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
      diagnostics = {
        virtual_text = false,
      },
      format = {
        timeout_ms = 500,
      },
      -- inlay_hints = { enabled = false },
      servers = {
        -- make sure the proto server is insalled with default config
        buf_ls = {},
        -- main go lsp
        gopls = {
          settings = {
            gopls = {
              buildFlags = { "-tags=manual_test" },
              ["local"] = "dev.azure.com/schwarzit/lidl.wawi-core",
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
              -- do not override string highlighting for sql query, any side effects?
              noSemanticString = true,
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
      },
    },
  },
}

-- LSP[gopls] Invalid settings: setting option "analyses": this setting is deprecated, use "the 'fieldalignment' analyzer was removed in gopls/v0.17.0; instead, hover over struct fields to see size/offset information (https://go.dev/issue/66861)" instead
