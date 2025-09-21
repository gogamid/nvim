-- Basic autocommands
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function() vim.hl.on_yank() end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

-- Set filetype-specific settings
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = {"lua", "python"},
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = {"javascript", "typescript", "json", "html", "css"},
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function() vim.cmd("tabdo wincmd =") end,
})

-- Create directories when saving files
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "query",
    "grug-far",
    "help",
    "markdown",
    "oil",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, {force = true})
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

-- wrap and do not check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = {"text", "plaintex", "typst", "gitcommit", "markdown"},
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.textwidth = 0
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup,
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>close<CR>", {
      buffer = args.buf,
      silent = true,
      desc = "Quit terminal window",
    })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Check if current working directory is within NEXUS_REPO
    if vim.fn.getcwd():find(vim.fn.expand("$NEXUS_REPO"), 1, true) == 1 then
      require("modules.pb_snips").compute_and_add_alias_import_snippets()
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Toggle CodeCompanion with q",
  group = augroup,
  pattern = {
    "codecompanion",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("CodeCompanionChat Toggle")
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Toggle CodeCompanion",
      })
    end)
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Organize imports for Go files",
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.code_action({apply = true, context = {only = {"source.organizeImports"}, diagnostics = {}}})
  end,
})

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local opts = {buffer = event.buf}
    -- Information
    vim.keymap.set("n", "K", vim.lsp.buf.hover, {buffer = event.buf, desc = "Hover"})

    -- Code actions
    vim.keymap.set({"n", "v"}, "<leader>ca", vim.lsp.buf.code_action, {buffer = event.buf, desc = "Code Action"})
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, {buffer = event.buf, desc = "Rename"})

    -- Diagnostics
    vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, {buffer = event.buf, desc = "Open Diagnostic"})
    vim.keymap.set("n", "<leader>cD", vim.diagnostic.setloclist, {buffer = event.buf, desc = "Quickfix Diagnostics"})
  end,
})
