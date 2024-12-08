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

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    LazyVim.lsp.on_supports_method("textDocument/foldingRange", function()
      vim.wo.foldmethod = "expr"
      vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
    end)
  end,
})
