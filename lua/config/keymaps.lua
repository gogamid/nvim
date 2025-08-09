-- better up and down
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Normal mode mappings
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

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

vim.keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
vim.keymap.set("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
vim.keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Better indenting in visual mode
vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Copy Full File-Path
vim.keymap.set("n", "<leader>fP", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("file:", path)
end, { desc = "Copy Full File-Path" })

-- Clear search and stop snippet on escape
vim.keymap.set({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

vim.keymap.set("n", "<leader>fu", function()
  local url = vim.fn.expand("<cWORD>")
  if url:match("^https?://") then
    url = url:gsub("%W+$", "") -- remove non alphanumeric characters in the end of the url
    vim.fn.setreg("+", url)
    vim.ui.open(url)
  end
end, { desc = "Go to URL under cursor" })

vim.keymap.set("n", "<leader>l", ":Lazy<CR>", { desc = "Lazy" })

local function add_import_to_go_file_if_not_exists(package_path, alias)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local import_line = string.format('%s "%s"', alias, package_path)

  -- Check if import already exists
  for _, line in ipairs(lines) do
    if line:find('"' .. package_path .. '"', 1, true) then
      return -- Import exists, skip
    end
  end

  -- Find insertion point
  local import_start, import_end, package_line = nil, nil, nil
  for i, line in ipairs(lines) do
    if line:match("^import %($") then
      import_start = i
    elseif import_start and line:match("^%)$") then
      import_end = i - 1 -- Insert before the closing parenthesis
      break
    elseif line:match("^package ") then
      package_line = i
    end
  end

  if import_start and import_end then
    -- Add to existing import block at the bottom
    vim.api.nvim_buf_set_lines(bufnr, import_end, import_end, false, { "\t" .. import_line })
  elseif package_line then
    -- Create new import block after package line
    local new_block = { "", "import (", "\t" .. import_line, ")" }
    vim.api.nvim_buf_set_lines(bufnr, package_line, package_line, false, new_block)
  end
end

local function compute_and_add_alias_import_snippets()
  local ls = require("luasnip")
  local s = ls.s
  local i = ls.i
  local t = ls.t
  local e = require("luasnip.util.events")

  -- Create a snippet that auto-imports the package
  local function import_pkg(trigger, alias, package_path)
    return s(trigger, {
      t(alias),
      i(1, "", {
        node_callbacks = {
          [e.enter] = function()
            add_import_to_go_file_if_not_exists(package_path, alias)
          end,
        },
      }),
    })
  end

  -- Find git root directory
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return
  end

  -- Find all service.go files
  local service_files = vim.fn.systemlist("find " .. git_root .. " -name 'service.go' -type f")

  local imports = {}
  local seen_triggers = {}

  -- Process each service.go file
  for _, file in ipairs(service_files) do
    local lines = vim.fn.readfile(file)
    local in_import_block = false

    for _, line in ipairs(lines) do
      local trimmed = vim.trim(line)

      -- Detect import block start
      if trimmed:match("^import%s*%(") then
        in_import_block = true
      -- Detect import block end
      elseif in_import_block and trimmed == ")" then
        in_import_block = false
      -- Extract aliased imports (lines with space before quoted path)
      elseif in_import_block and trimmed:match('^%w+%s+"') then
        local alias, package_path = trimmed:match('^(%w+)%s+"([^"]+)"')
        if alias and package_path and not seen_triggers[alias] then
          seen_triggers[alias] = true
          table.insert(imports, {
            trigger = alias,
            alias = alias,
            package_path = package_path,
          })
        end
      end
    end
  end

  -- Create snippets
  local snippets = {}
  for _, import in ipairs(imports) do
    local snippet = import_pkg(import.trigger, import.alias, import.package_path)
    table.insert(snippets, snippet)
  end

  -- Add snippets to Go filetype
  if #snippets > 0 then
    ls.add_snippets("go", snippets, { key = "go_imports_dynamic" })
    vim.notify("Added " .. #snippets .. " import snippets for Go files", vim.log.levels.INFO)
  else
    vim.notify("No aliased imports found in service.go files", vim.log.levels.WARN)
  end
end

vim.keymap.set(
  "n",
  "<leader>cs",
  compute_and_add_alias_import_snippets,
  { desc = "Copute and add alias import snippets" }
)
