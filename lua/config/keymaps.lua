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
-- later replaced with smart-splits
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

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

vim.keymap.set("x", "<leader>ri", function()
  local lines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = vim.fn.mode() })
  vim.fn.feedkeys(":" .. "lua print(vim.inspect(" .. lines[1] .. "))", "m")
end, { desc = "Inspect visual selection" })

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


-- create user command
-- require("modules.bionic").setup({ prefix_length = 2, auto_activate = false, filetypes = { "markdown" } })
-- vim.keymap.set("n", "<leader>uB", ":BionicToggle<CR>", { desc = "Toggle Bionic Read" })

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

-- create user command
-- vim.keymap.set("n", "<leader>p", require("modules.pomodoro").menu, { desc = "Pomodoro Menu" })

vim.keymap.set("n", "<leader>fl", ":e!<CR>", { desc = "Load file" })
