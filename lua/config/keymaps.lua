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
--use C arrow keys for resizing, in wezterm use Cmd hjkl
-- vim.keymap.set("n", "<D-h>", ss.resize_left)
-- vim.keymap.set("n", "<D-j>", ss.resize_down)
-- vim.keymap.set("n", "<D-k>", ss.resize_up)
-- vim.keymap.set("n", "<D-l>", ss.resize_right)

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
