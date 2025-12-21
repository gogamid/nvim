local M = {}

local fname = "translations.lua"

local function error(msg)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.ERROR, { title = fname })
  end)
end

local function info(msg)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.INFO, { title = fname })
  end)
end

local default_opts = {
  translation_file = "en_DEV.json",
  highlight = "Conceal",
  active = {
    typescript = true,
    vue = true,
    go = true,
  },
}

local ns = vim.api.nvim_create_namespace("translations")

-- Cache for translations file data and line mappings
local cache = {
  json_file = nil,
  data = nil,
  key_lines = {}, -- key -> line number mapping
}

-- language: scheme
local ts_translation_query = [[
(
  (call_expression
    function: (identifier) @ident
    arguments: (arguments
      (string
        (string_fragment) @translation.key)))
  (#any-of? @ident "__" "m")
)
]]

-- language: scheme
local go_translation_query = [[
((index_expression 
  operand: (identifier) @ident 
  index: (interpreted_string_literal 
    (interpreted_string_literal_content) @translation.key)) 
  (#any-of? @ident "translations" "translation")) 
]]

local query_by_lang = {
  typescript = ts_translation_query,
  go = go_translation_query,
}

local function load_translations(json_file)
  if not json_file then
    return nil
  end

  local ok, result = pcall(function()
    local content = table.concat(vim.fn.readfile(json_file), "\n")
    return vim.json.decode(content)
  end)

  return ok and result or nil
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

---@param trees table<integer, TSTree>
local function handle_trees(trees, lang, buf, top, bottom, translations)
  local query = vim.treesitter.query.parse(lang, query_by_lang[lang])
  for _, node in pairs(trees) do
    for _, match, _ in query:iter_matches(node:root(), buf, top, bottom + 1) do
      for id, nodes in pairs(match) do
        local capture_name = query.captures[id]
        if capture_name == "translation.key" then
          local key_node = nodes[1]
          local key_text = vim.treesitter.get_node_text(key_node, buf)
          local start_row, start_col, end_row, end_col = key_node:range()

          local value = get_translation_value(key_text, translations)

          vim.api.nvim_buf_set_extmark(buf, ns, end_row, end_col + 1, {
            virt_text = { { value, M.opts.highlight } },
            -- virt_text_pos = "inline",
            hl_mode = "combine",
            spell = true,
          })
        end
      end
    end
  end
end

local function build_key_line_map(json_file)
  local ok, lines = pcall(vim.fn.readfile, json_file)
  if not ok then
    return {}
  end

  local key_lines = {}
  for line_num, line in ipairs(lines) do
    -- Match pattern like "key": value
    local key = line:match('"([^"]+)"%s*:')
    if key then
      key_lines[key] = line_num
    end
  end
  return key_lines
end

local function on_win(_, win, buf, top, bottom)
  local filetype = vim.bo[buf].filetype
  if not M.opts.active[filetype] then
    return false
  end

  vim.api.nvim_buf_clear_namespace(buf, ns, top, bottom)

  local lt = vim.treesitter.get_parser(buf)
  if not lt then
    return false
  end

  --- @type table<string, vim.treesitter.LanguageTree>
  local ltrees = {}
  if query_by_lang[lt:lang()] ~= nil then
    ltrees[lt:lang()] = lt
  else
    for lang, ltree in pairs(lt:children()) do
      if query_by_lang[lang] ~= nil then
        ltrees[lang] = ltree
      end
    end
  end
  if not next(ltrees) then
    return false
  end

  local json_file = vim.fn.findfile(M.opts.translation_file)
  local translations = load_translations(json_file)

  -- Update cache
  if json_file and translations then
    cache.json_file = json_file
    cache.data = translations
    cache.key_lines = build_key_line_map(json_file)
  end

  for lang, ltree in pairs(ltrees) do
    local tstrees = ltree:parse({ top, bottom + 1 })
    if tstrees then
      handle_trees(tstrees, lang, buf, top, bottom + 1, translations)
    end
  end

  return true
end

local function add_key_to_json(json_file, key, value)
  local ok, lines = pcall(vim.fn.readfile, json_file)
  if not ok then
    error("Failed to read JSON file")
    return false
  end

  -- Verify it's valid JSON
  local file_content = table.concat(lines, "\n")
  local parse_ok, data = pcall(vim.json.decode, file_content)
  if not parse_ok then
    error("Invalid JSON file")
    return false
  end

  if data[key] then
    error("Key '" .. key .. "' already exists")
    return false
  end

  local insert_line = nil
  for i, line in ipairs(lines) do
    if line:match("{") then
      insert_line = i
      break
    end
  end

  if not insert_line then
    error("Invalid JSON format")
    return false
  end

  -- Format the new key-value pair with proper indentation
  local indent = lines[insert_line + 1]:match("^(%s*)")
  if indent == nil then
    indent = "  "
  end

  local new_line = indent .. '"' .. key .. '": ' .. vim.json.encode(value) .. ","

  -- Insert the new key-value pair
  table.insert(lines, insert_line + 1, new_line)

  local write_ok = pcall(function()
    vim.fn.writefile(lines, json_file)
  end)

  if write_ok then
    info("Added key '" .. key .. "' to translations")
    return true
  else
    error("Failed to write to JSON file")
    return false
  end
end

local function get_key_at_cursor()
  local buf = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[buf].filetype

  if not M.opts.active[filetype] then
    error("translations not active for this filetype")
    return nil
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1

  local lt = vim.treesitter.get_parser(buf)
  if not lt then
    error("No treesitter parser available")
    return nil
  end

  local query = vim.treesitter.query.parse(lt:lang(), query_by_lang[lt:lang()] or "")
  local root = lt:parse()[1]:root()

  for _, match in query:iter_matches(root, buf) do
    for id, nodes in pairs(match) do
      if query.captures[id] == "translation.key" then
        local key_node = nodes[1]
        local start_row, start_col, end_row, end_col = key_node:range()

        if start_row == row and col >= start_col and col <= end_col then
          return vim.treesitter.get_node_text(key_node, buf)
        end
      end
    end
  end

  error("No translation key found at cursor")
  return nil
end

M.navigate_to_key = function()
  local key = get_key_at_cursor()
  if not key then
    return
  end

  -- Use cached json_file, fall back to finding it
  local json_file = cache.json_file or vim.fn.findfile(M.opts.translation_file)
  if not json_file or json_file == "" then
    error("Translation file not configured")
    return
  end

  -- Try cached line mapping first
  local line_num = cache.key_lines[key]

  if not line_num then
    -- Key not found, ask user for value
    vim.ui.input({ prompt = "Enter value for '" .. key .. "': " }, function(value)
      if value then
        if add_key_to_json(json_file, key, value) then
          -- Invalidate cache
          cache.json_file = nil
          cache.data = nil
          cache.key_lines = {}
          -- Reload translations display
          vim.api.nvim_exec_autocmds("User", { pattern = "TranslationsUpdated" })
        end
      end
    end)
  else
    -- Open the JSON file at the key location
    vim.cmd("edit " .. json_file)
    vim.api.nvim_win_set_cursor(0, { line_num, 0 })
  end
end

M.init = function()
  vim.api.nvim_set_decoration_provider(ns, { on_win = on_win })

  -- Translations navigation
  vim.keymap.set("n", "gj", function()
    M.navigate_to_key()
  end, { noremap = true, silent = true, desc = "Go to translation key" })
end

M.setup = function(opts)
  M.opts = vim.tbl_deep_extend("keep", opts or {}, default_opts)
  M.init()

  info("done")
end

return M
