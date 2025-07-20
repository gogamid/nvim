-- ============================================================================
-- LSP
-- ============================================================================

vim.lsp.enable({
  "lua_ls",
  "bashls",
  "taplo",
  "gopls",
})

-- autoformat with lsp on save
-- vim.api.nvim_create_autocmd("BufWritePre", {
--     -- buffer = buffer,
--     callback = function()
--         vim.lsp.buf.format { async = true }
--     end
-- })
--
-- vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "Format file" })

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = { buffer = event.buf }

    -- -- Navigation
    -- vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    -- vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    -- vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
    -- vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    -- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)

    -- Information
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

    -- Code actions
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)

    -- Diagnostics
    vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, opts)
  end,
})

-- Better LSP UI
vim.diagnostic.config({
  -- virtual_lines = true,
  virtual_text = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "ErrorMsg",
      [vim.diagnostic.severity.WARN] = "WarningMsg",
    },
  },
})

vim.api.nvim_create_user_command("LspInfo", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    print("No LSP clients attached to current buffer")
  else
    for _, client in ipairs(clients) do
      print("LSP: " .. client.name .. " (ID: " .. client.id .. ")")
    end
  end
end, { desc = "Show LSP client info" })

local function organize_imports_if_available()
  local params = vim.lsp.util.make_range_params(0, "utf-8")
  vim.lsp.buf_request(0, "textDocument/codeAction", params, function(err, result, _)
    if err or not result or vim.tbl_isempty(result) then
      return
    end
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
end
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "go" },
  callback = function(_)
    organize_imports_if_available()
  end,
})
