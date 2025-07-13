-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local function augroup(name)
  return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end
-- wrap and do not check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "kbd",
  callback = function()
    vim.bo.filetype = "ht"
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "config",
  callback = function()
    vim.bo.filetype = "config"
  end,
})

--Quicktest go output PASS and FAIL highlights
-- Define highlight groups
vim.cmd("highlight PassHighlight ctermfg=green guifg=green")
vim.cmd("highlight FailHighlight ctermfg=red guifg=red")
vim.cmd("highlight OkHighlight ctermfg=cyan guifg=cyan")

-- Apply highlights based on filetype
vim.api.nvim_create_autocmd("FileType", {
  pattern = "quicktest-output",
  callback = function()
    vim.cmd("syntax match PassKeyword /\\<PASS\\>/ containedin=ALL")
    vim.cmd("syntax match FailKeyword /\\<FAIL\\>/ containedin=ALL")
    vim.cmd("syntax match OkKeyword /\\<ok\\>/ containedin=ALL")
    vim.cmd("highlight link PassKeyword PassHighlight")
    vim.cmd("highlight link FailKeyword FailHighlight")
    vim.cmd("highlight link OkKeyword OkHighlight")
  end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "quicktest-output",
    "query",
    "grug-far",
    "help",
    "markdown",
    "oil",
    "codecompanion",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", {
      buffer = event.buf,
      silent = true,
      desc = "Quit buffer",
    })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_esc"),
  pattern = {
    "oil",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "<esc>", "<cmd>close<cr>", {
      buffer = event.buf,
      silent = true,
      desc = "Quit buffer",
    })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    LazyVim.lsp.on_supports_method("textDocument/foldingRange", function()
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
    end)
    -- LazyVim.lsp.on_supports_method("source.organizeImports", function()
    --   vim.api.nvim_create_autocmd("BufWritePre", {
    --     buffer = args.buf,
    --     callback = organize_imports_if_available,
    --   })
    -- end)
  end,
})

-- Set focused directory as current working directory
local set_cwd = function()
  local path = (MiniFiles.get_fs_entry() or {}).path
  if path == nil then
    return vim.notify("Cursor is not on valid entry")
  end
  vim.fn.chdir(vim.fs.dirname(path))
end

-- Yank in register full path of entry under cursor
local yank_path = function()
  local path = (MiniFiles.get_fs_entry() or {}).path
  if path == nil then
    return vim.notify("Cursor is not on valid entry")
  end
  vim.fn.setreg(vim.v.register, path)
end

-- Open path with system default handler (useful for non-text files)
local ui_open = function()
  vim.ui.open(MiniFiles.get_fs_entry().path)
end

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    local b = args.data.buf_id
    vim.keymap.set("n", "g~", set_cwd, { buffer = b, desc = "Set cwd" })
    vim.keymap.set("n", "gX", ui_open, { buffer = b, desc = "OS open" })
    vim.keymap.set("n", "gy", yank_path, { buffer = b, desc = "Yank path" })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "copilot-*",
  callback = function()
    require("CopilotChat").config.window.width = vim.o.columns < 180 and 0.8 or 0.5
  end,
})
