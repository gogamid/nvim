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
