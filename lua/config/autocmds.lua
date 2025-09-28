-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Create directories when saving files
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "checkhealth", "help", "lspinfo", "notify", "query", "help", "markdown" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
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
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.textwidth = 0
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
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
