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
      inlay_hints = { enabled = false },
      servers = {
        gopls = {
          settings = {
            gopls = {
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
            },
          },

          on_attach = function(client, bufnr)
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function(event)
                organize_imports_if_available()
              end,
            })
          end,
          --reuse gopls server
          cmd = { "gopls", "-remote=auto", "-remote.listen.timeout", "2m" },
        },
        clangd = {
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        },
        eslint = {
          -- auto command to fix sorting, imports etc in frontend
          on_attach = function(client, bufnr)
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              command = "EslintFixAll",
            })
          end,
        },
      },
    },
  },
}
