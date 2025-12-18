-- better up and down
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Normal mode mappings
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
vim.keymap.set("n", "<leader>qq", "<cmd>wqall<cr>", { desc = "Save All and Quit All" })

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Better window navigation
vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)

vim.keymap.set("v", "<C-h>", require("smart-splits").resize_left)
vim.keymap.set("v", "<C-j>", require("smart-splits").resize_down)
vim.keymap.set("v", "<C-k>", require("smart-splits").resize_up)
vim.keymap.set("v", "<C-l>", require("smart-splits").resize_right)

-- Splitting
vim.keymap.set("n", "<leader>|", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>-", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>wd", "<C-w>c", { desc = "Delete Window" })

vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
vim.keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Increment/decrement
vim.keymap.set({ "n", "v" }, "+", "<C-a>", { desc = "Increment numbers", noremap = true })
vim.keymap.set({ "n", "v" }, "-", "<C-x>", { desc = "Decrement numbers", noremap = true })

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- paste and delete without yanking
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Clear search and stop snippet on escape
vim.keymap.set({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

vim.keymap.set("n", "go", function()
  local url = vim.fn.expand("<cWORD>")
  if url:match("https?://") then
    url = url:match("https?://[%w%-%._~:/%?#%[%]@!$&'()*+,;=]+")
    url = url and url:gsub("[%)%.]+$", "") or url
    vim.fn.setreg("+", url)
    vim.fn.jobstart({ "open", url }, { detach = true })
  end
end, { desc = "Go to URL under cursor" })

require("modules.bionic").setup({ prefix_length = 2, auto_activate = false, filetypes = { "markdown" } })
vim.keymap.set("n", "<leader>uB", ":BionicToggle<CR>", { desc = "Toggle Bionic Read" })

--stylua: ignore
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)

    vim.lsp.inlay_hint.enable(true)

    -- Information
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf, desc = "Hover" })

    -- Code actions
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = args.buf, desc = "Code Action" })
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { buffer = args.buf, desc = "Rename" })
    vim.keymap.set("n", '<leader>cl', vim.lsp.codelens.run, { buffer = args.buf, desc = "CodeLens" })

    -- Diagnostics
    vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { buffer = args.buf, desc = "Open Diagnostic" })
    vim.keymap.set("n", "<leader>cD", vim.diagnostic.setloclist, { buffer = args.buf, desc = "Quickfix Diagnostics" })

    -- Code actions
    vim.keymap.set("n", "gd", function() Snacks.picker.lsp_definitions() end, { desc = "Definitions" })
    vim.keymap.set("n", "gD", function() Snacks.picker.lsp_declarations() end, { desc = "Declarations" })
    vim.keymap.set("n", "gr", function() Snacks.picker.lsp_references() end, { nowait = true, desc = "References" })
    vim.keymap.set("n", "gi", function() Snacks.picker.lsp_implementations() end, { desc = "Implementation" })
    vim.keymap.set("n", "gt", function() Snacks.picker.lsp_type_definitions() end, { desc = "Type Definition" })

  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Organize imports for Go files",
  pattern = "*.go",
  callback = function()
    vim.inspect("Organize imports for Go files")
    local params = vim.lsp.util.make_range_params(0, "utf-8")
    vim.lsp.buf_request(0, "textDocument/codeAction", params, function(err, result, _)
      if err or not result or vim.tbl_isempty(result) then
        return
      end
      for _, action in pairs(result) do
        if action.kind == "source.organizeImports" then
          if action.command then
            vim.lsp.buf.code_action({
              apply = true,
              context = { only = { "source.organizeImports" }, diagnostics = {} },
            })
          elseif action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
          end
          return
        end
      end
    end)
  end,
})

local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end
vim.keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
vim.keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
vim.keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

vim.keymap.set("n", "<leader>uI", function()
  vim.cmd("InspectTree")
  vim.cmd("EditQuery")
end, { desc = "Inspect and Edit Query" })
