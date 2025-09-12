-- better up and down
vim.keymap.set({"n", "x"}, "j", "v:count == 0 ? 'gj' : 'j'", {desc = "Down", expr = true, silent = true})
vim.keymap.set({"n", "x"}, "<Down>", "v:count == 0 ? 'gj' : 'j'", {desc = "Down", expr = true, silent = true})
vim.keymap.set({"n", "x"}, "k", "v:count == 0 ? 'gk' : 'k'", {desc = "Up", expr = true, silent = true})
vim.keymap.set({"n", "x"}, "<Up>", "v:count == 0 ? 'gk' : 'k'", {desc = "Up", expr = true, silent = true})

-- Normal mode mappings
vim.keymap.set({"i", "x", "n", "s"}, "<C-s>", "<cmd>w<cr><esc>", {desc = "Save File"})
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", {desc = "Quit All"})

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", {desc = "Next search result (centered)"})
vim.keymap.set("n", "N", "Nzzzv", {desc = "Previous search result (centered)"})
vim.keymap.set("n", "<C-d>", "<C-d>zz", {desc = "Half page down (centered)"})
vim.keymap.set("n", "<C-u>", "<C-u>zz", {desc = "Half page up (centered)"})

-- Delete without yanking
vim.keymap.set({"n", "v"}, "<leader>d", '"_d', {desc = "Delete without yanking"})

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", {desc = "Next buffer"})
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", {desc = "Previous buffer"})

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
vim.keymap.set("n", "<leader>|", ":vsplit<CR>", {desc = "Split window vertically"})
vim.keymap.set("n", "<leader>-", ":split<CR>", {desc = "Split window horizontally"})
vim.keymap.set("n", "<leader>wd", "<C-w>c", {desc = "Delete Window"})

vim.keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", {desc = "Last Tab"})
vim.keymap.set("n", "<leader><tab>o", "<cmd>tabonly<cr>", {desc = "Close Other Tabs"})
vim.keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", {desc = "First Tab"})
vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", {desc = "New Tab"})
vim.keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", {desc = "Next Tab"})
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", {desc = "Close Tab"})
vim.keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", {desc = "Previous Tab"})

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", {desc = "Indent left and reselect"})
vim.keymap.set("v", ">", ">gv", {desc = "Indent right and reselect"})

-- Increment/decrement
vim.keymap.set({"n", "v"}, "+", "<C-a>", {desc = "Increment numbers", noremap = true})
vim.keymap.set({"n", "v"}, "-", "<C-x>", {desc = "Decrement numbers", noremap = true})

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", {desc = "Join lines and keep cursor position"})

-- Clear search and stop snippet on escape
vim.keymap.set({"i", "n", "s"}, "<esc>", function()
  vim.cmd("noh")
  return "<esc>"
end, {expr = true, desc = "Escape and Clear hlsearch"})

vim.keymap.set("n", "gf", function()
  local url = vim.fn.expand("<cWORD>")
  if url:match("https?://") then
    url = url:match("https?://[%w%-%._~:/%?#%[%]@!$&'()*+,;=]+")
    url = url and url:gsub("[%)%.]+$", "") or url
    vim.fn.setreg("+", url)
    vim.fn.jobstart({"open", url}, {detach = true})
  end
end, {desc = "Go to URL under cursor"})

vim.keymap.set("n", "<leader>l", ":Lazy<CR>", {desc = "Lazy"})

vim.keymap.set( "n", "<leader>cs", require("config.modules.pb_snips").compute_and_add_alias_import_snippets, {desc = "Copute and add alias import snippets"})

-- paste without yanking
vim.keymap.set("x", "<leader>p", [["_dP]])

-- -- copy into system clipboard
-- vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
-- vim.keymap.set("n", "<leader>Y", [["+Y]])

-- delete without yanking
vim.keymap.set({"n", "v"}, "<leader>d", '"_d')

require("config.modules.bionic").setup({prefix_length = 2, auto_activate = true, filetypes = {"markdown"}})
vim.keymap.set("n", "<leader>uB", ":BionicToggle<CR>", {desc = "Toggle Bionic Read"})
