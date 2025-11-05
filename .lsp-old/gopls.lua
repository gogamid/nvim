return {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  capabilities = {
    textDocument = {
      codeAction = {
        dynamicRegistration = true,
        codeActionLiteralSupport = {
          codeActionKind = {
            valueSet = {
              "quickfix",
              "refactor",
              "refactor.extract",
              "refactor.inline",
              "refactor.move",
              "refactor.rewrite",
              "source",
              "source.organizeImports",
              "source.fixAll",
            },
          },
        },
        resolveSupport = {
          properties = { "edit" },
        },
      },
    },
  },
  on_init = function(_)
    vim.api.nvim_create_autocmd("BufWritePre", {
      desc = "Organize imports for Go files",
      pattern = "*.go",
      callback = function()
        vim.inspect("Organize imports for Go files")
        local params = vim.lsp.util.make_range_params(0, "utf-8")
        vim.lsp.buf_request(0, "textDocument/codeAction", params, function(err, result, _)
          if err or not result or vim.tbl_isempty(result) then return end
          for _, action in pairs(result) do
            if action.kind == "source.organizeImports" then
              if action.command then
                vim.lsp.buf.code_action({ apply = true, context = { only = { "source.organizeImports" }, diagnostics = {} } })
              elseif action.edit then
                vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
              end
              return
            end
          end
        end)
      end,
    })
  end,
  settings = {
    gopls = {
      gofumpt = true,
      buildFlags = { "-tags=manual_test" },
      ["local"] = os.getenv("GO_LOCAL_PKG"),
      staticcheck = true,
      analyses = {
        shadow = true,
        unusedvariable = true,
        nilness = true,
        unusedwrite = true,
        useany = true,
        ST1003 = false,
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
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      usePlaceholders = true,
      completeUnimported = true,
      directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
      semanticTokens = false, -- overrides injections
      diagnosticsTrigger = "Save",
    },
  },
}
