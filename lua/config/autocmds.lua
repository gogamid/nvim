local function augroup(name)
  return vim.api.nvim_create_augroup("ig_" .. name, { clear = true })
end

-- ---@param filetype? string
-- local function checkForTreesitter(filetype)
--   if vim.o.diff then
--     return
--   end
--
--   if not filetype then
--     filetype = vim.bo.filetype
--   end
--   local win = vim.api.nvim_get_current_win()
--
--   local ok, hasParser = pcall(vim.treesitter.query.get, filetype, "folds")
--
--   if ok and hasParser then
--     vim.wo[win][0].foldmethod = "expr"
--     vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
--   else
--     vim.wo[win][0].foldexpr = ""
--     vim.wo[win][0].foldtext = "v:lua.custom_foldtext()"
--   end
-- end
--
-- vim.api.nvim_create_autocmd("FileType", {
--   desc = "Enable treesitter folding else fallback to indent folding",
--   group = augroup("folding"),
--   callback = function(ctx)
--     checkForTreesitter(ctx.match)
--   end,
-- })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Return to last edit position when opening files",
  group = augroup("return_to_last_edit_position"),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  desc = "Auto resize splits when window is resized",
  group = augroup("auto_resize"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  desc = "Create directories when saving files",
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Wrap text for text filetypes",
  group = augroup("wrap_text_filetypes"),
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
  group = augroup("close_with_q"),
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
  desc = "Add pb import aliases on nexus repo",
  group = augroup("add_pb_import_aliases"),
  callback = function()
    if vim.fn.getcwd():find(vim.fn.expand("$NEXUS_REPO"), 1, true) == 1 then
      require("modules.pb_snips").compute_and_add_alias_import_snippets()
    end
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Reload file when it changed outside of vim",
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  desc = "Set conceallevel to 0 for json files",
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("setup_auto_root", {}),
  callback = function(data)
    vim.o.autochdir = false
    local root = vim.fs.root(data.buf, { "service.yaml", ".git" })
    if root == nil or root == vim.fn.getcwd() then
      return
    end
    vim.fn.chdir(root)
    vim.api.nvim_echo({ { "chdir to " .. root, "WarningMsg" } }, true, {})
  end,
  desc = "Find root and change current directory",
  -- once = true,
})

local ns = vim.api.nvim_create_namespace("translation key values")
local query_str = [[
(
  (call_expression
    function: (identifier) @ident
    arguments: (arguments
      (string
        (string_fragment) @translation.key)))
  (#any-of? @ident "__" "m")
)
]]
local highlight = "Conceal"

local function find_translation_file()
  local cwd = vim.fn.getcwd()
  local json_file = cwd .. "/src/i18n/en_DEV.json"

  if vim.fn.filereadable(json_file) == 1 then
    return json_file
  end

  return nil
end

local function load_translations(json_file)
  if not json_file then
    return nil
  end

  local ok, result = pcall(function()
    local content = table.concat(vim.fn.readfile(json_file), "\n")
    return vim.json.decode(content)
  end)

  if ok then
    return result
  else
    return nil
  end
end

local function get_translation_value(key, translations)
  if not key or key == "" then
    return ""
  end

  if not translations then
    return "err"
  end

  local value = translations[key]
  if value and type(value) == "string" then
    return value
  else
    return ""
  end
end

local function on_win(_, win, buf, top, bottom)
  local filetype = vim.bo[buf].filetype
  if filetype ~= "typescript" and filetype ~= "typescriptreact" and filetype ~= "vue" then
    return false
  end

  vim.api.nvim_buf_clear_namespace(buf, ns, top, bottom)

  -- For Vue files, get the injected TypeScript parser
  local parser
  if filetype == "vue" then
    local lang_parser = vim.treesitter.get_parser(buf, "typescript")
    parser = lang_parser and lang_parser:children().typescript or lang_parser
  else
    parser = vim.treesitter.get_parser(buf, filetype)
  end
  
  if not parser then
    return false
  end
  local trees = parser:parse()
  local tree = trees and trees[1]
  if not tree then
    return false
  end

  -- Load translations once per window render
  local json_file = find_translation_file()
  local translations = load_translations(json_file)

  -- Always use TypeScript query since that's where translation calls exist
  local query = vim.treesitter.query.parse("typescript", query_str)
  for _, match, _ in query:iter_matches(tree:root(), buf, top, bottom + 1) do
    for id, nodes in pairs(match) do
      local capture_name = query.captures[id]
      if capture_name == "translation.key" then
        local key_node = nodes[1]
        local key_text = vim.treesitter.get_node_text(key_node, buf)
        local start_row, start_col, end_row, end_col = key_node:range()

        local value = get_translation_value(key_text, translations)

        -- Set virtual text showing actual value after the key
        vim.api.nvim_buf_set_extmark(buf, ns, end_row, end_col + 1, {
          virt_text = { { " → " .. value, highlight } },
          virt_text_pos = "inline",
        })
      end
    end
  end
  return true
end

vim.api.nvim_set_decoration_provider(ns, { on_win = on_win })
