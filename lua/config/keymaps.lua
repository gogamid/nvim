-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")

local ss = require("smart-splits")
vim.keymap.set("v", "<C-h>", ss.resize_left)
vim.keymap.set("v", "<C-j>", ss.resize_down)
vim.keymap.set("v", "<C-k>", ss.resize_up)
vim.keymap.set("v", "<C-l>", ss.resize_right)

-- moving between splits
vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)
vim.keymap.set("n", "<C-\\>", require("smart-splits").move_cursor_previous)
-- swapping buffers between windows
vim.keymap.set("n", "<leader><leader>h", ss.swap_buf_left)
vim.keymap.set("n", "<leader><leader>j", ss.swap_buf_down)
vim.keymap.set("n", "<leader><leader>k", ss.swap_buf_up)
vim.keymap.set("n", "<leader><leader>l", ss.swap_buf_right)

-- my simple snacks terminal for showing cypress results
local ui_test = require("custom.ui_test")
vim.keymap.set("n", "<leader>tu", ui_test.run_cypress, { desc = "Run Cypress tests for the current buffer" })

-- LazyVim doesn't expose float configuration
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ float = false, severity = severity })
  end
end
local map = LazyVim.safe_keymap_set
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- disable Lazy keymap and use my own
vim.keymap.set("n", "<leader>l", "", { silent = true })

if vim.g.started_by_firenvim == true then
  vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<Esc>:wq<CR>")
end

vim.keymap.set("x", "p", "P", { noremap = true }) -- Use 'P' (preserves register)
