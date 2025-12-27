-- Buf autocommands in order BufReadPost, BufEnter, BufWritePre

vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
  desc = "Change current directory to buffer's root",
  callback = function(data)
    vim.o.autochdir = false
    local root = vim.fs.root(data.buf, { "Dockerfile", "Buildfile.yaml", "service.yaml", "Makefile", ".git" })
    if root == nil or root == vim.fn.getcwd() then
      return
    end
    vim.fn.chdir(root)
    vim.api.nvim_echo({ { "chdir to " .. root, "Conceal" } }, true, {})
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Return to last edit position when opening files",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

local workspace = vim.fn.expand("$NEXUS_REPO")
vim.api.nvim_create_autocmd("BufEnter", {
  desc = "nexus actions",
  pattern = workspace .. "**",
  callback = function()
    vim.env.DEPLOY_TO_MULTI_REGION = false
    require("modules.translations").setup()
    require("modules.imports").add_snippets()
  end,
  once = true,
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
  desc = "Refresh codelenses",
  pattern = { "*.go", "*.lua" },
  callback = function()
    vim.lsp.codelens.refresh()
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  desc = "Create directories when saving files",
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  desc = "Auto resize splits when window is resized",
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Add q mapping to quit terminal window",
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>close<CR>", {
      buffer = args.buf,
      silent = true,
      desc = "Quit terminal window",
    })
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Reload file when it changed outside of vim",
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  desc = "Set conceallevel to 0 for json files",
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Wrap text for text filetypes",
  pattern = "minifiles",
  callback = function()
    local letters = "@"
    local digits = "48-57"
    local accented_chars = "192-255"
    local keywords = { letters, digits, accented_chars }
    vim.opt_local.iskeyword = table.concat(keywords, ",")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Wrap text for text filetypes",
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Close file with <q>",
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
  },
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
