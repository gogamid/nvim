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
  -- file name searched for, relative to the repository/ui/service directories
  translation_file = "en_DEV.json",
  highlight = "Comment",
  active = {
    typescript = true,
    vue = true,
    go = true,
  },
}

local ns = vim.api.nvim_create_namespace("translations")

-- Parsed tree-sitter queries per language (static configuration, built in setup)
local queries = {}

-- "<repo>::<domain>" -> { translations = { [key] = value }, locations = { [key] = { file, line } } }
-- Loaded once per project and refreshed on write/reload events, never on redraw.
local datasets = {}

-- Buffers that already have an on_lines callback scheduled
local pending = {}

local initialized = false

local ts_translation_query = [[
(
  (call_expression
    function: (identifier) @ident
    arguments: (arguments
      (string
        (string_fragment) @translation.key)))
  (#any-of? @ident "__" "m")
)

(
  (call_expression
    function: (identifier) @ident
    arguments: (arguments
      (object
        (pair
          key: (property_identifier) @prop
          value: (string
            (string_fragment) @translation.key)))))
  (#any-of? @ident "__" "m")
  (#eq? @prop "id")
)
]]

local go_translation_query = [[
((index_expression 
  operand: (identifier) @ident 
  index: (interpreted_string_literal 
    (interpreted_string_literal_content) @translation.key)) 
  (#any-of? @ident "translations" "translation")) 

((index_expression 
    operand: (selector_expression 
      operand: (identifier) 
      field: (field_identifier) @ident) 
    index: (interpreted_string_literal 
      (interpreted_string_literal_content) @translation.key))
  (#any-of? @ident "translations" "translation")) 
]]

local query_sources = {
  typescript = ts_translation_query,
  go = go_translation_query,
}

local function build_queries()
  queries = {}
  for lang, source in pairs(query_sources) do
    local ok, query = pcall(vim.treesitter.query.parse, lang, source)
    if ok then
      queries[lang] = query
    end
  end
end

local function repo_root(buf)
  local root = vim.fs.root(buf, ".git")
  if root then
    return vim.fs.normalize(root)
  end

  local env = vim.env.NEXUS_REPO
  if env and env ~= "" and vim.uv.fs_stat(env) then
    return vim.fs.normalize(env)
  end

  return vim.fs.normalize(vim.fn.getcwd())
end

local function domain_of(repo, buf)
  local path = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
  local relative = path:sub(1, #repo + 1) == repo .. "/" and path:sub(#repo + 2) or path
  return relative:match("^domains/([^/]+)/")
end

--- Translation files of a project, resolved with globs instead of walking the tree.
local function translation_files(repo, domain, name)
  local patterns = {
    "ui/components/i18n/" .. name,
    "ui/libs/i18n/" .. name,
  }

  if domain then
    patterns[#patterns + 1] = "domains/" .. domain .. "/translations/*/" .. name
    patterns[#patterns + 1] = "domains/" .. domain .. "/services/*/src/i18n/" .. name
    -- Note: domains/<domain>/services/*/main/translations/* is build output copied from
    -- domains/<domain>/translations and is deliberately ignored; the domain file is the source
  end

  local files = {}
  local seen = {}

  for _, pattern in ipairs(patterns) do
    for _, path in ipairs(vim.fn.globpath(repo, pattern, false, true)) do
      if not seen[path] then
        seen[path] = true
        files[#files + 1] = path
      end
    end
  end

  return files
end

local function read_translations(files)
  local translations = {}
  local locations = {}

  for _, path in ipairs(files) do
    local read_ok, lines = pcall(vim.fn.readfile, path)
    if read_ok then
      local decode_ok, data = pcall(vim.json.decode, table.concat(lines, "\n"))
      if decode_ok and type(data) == "table" then
        local key_lines = {}
        for line_num, line in ipairs(lines) do
          local key = line:match('^%s*"([^"]+)"%s*:')
          if key then
            key_lines[key] = line_num
          end
        end

        for key, value in pairs(data) do
          if type(value) == "string" then
            translations[key] = value
            locations[key] = { file = path, line = key_lines[key] }
          end
        end
      end
    end
  end

  return translations, locations
end

local function project_key(buf)
  local repo = repo_root(buf)
  local domain = domain_of(repo, buf)
  return repo, domain, repo .. "::" .. (domain or "")
end

local function load_dataset(repo, domain)
  local files = translation_files(repo, domain, M.opts.translation_file)
  if #files == 0 then
    return nil
  end

  local translations, locations = read_translations(files)
  return { translations = translations, locations = locations }
end

local function dataset_for(buf)
  local repo, domain, key = project_key(buf)

  local dataset = datasets[key]
  if not dataset then
    dataset = load_dataset(repo, domain)
    if not dataset then
      return nil
    end
    datasets[key] = dataset
  end

  return dataset
end

--- Parse the buffer range and return trees we can query.
--- The parser is parsed first: injected languages (Vue) only exist after that.
local function parsed_trees(parser, first, last)
  pcall(parser.parse, parser, { first, last })

  local lang = parser:lang()
  if queries[lang] then
    return { [lang] = parser }
  end

  local trees = {}
  local ok, children = pcall(parser.children, parser)
  if ok and children then
    for child_lang, child in pairs(children) do
      if queries[child_lang] then
        trees[child_lang] = child
      end
    end
  end

  return trees
end

local function decorate_tree(tree, lang, buf, dataset, first, last)
  local query = queries[lang]
  local ok, matches = pcall(query.iter_matches, query, tree:root(), buf, first, last)
  if not ok then
    return
  end

  for _, match in matches do
    for id, nodes in pairs(match) do
      if query.captures[id] == "translation.key" then
        local key_node = nodes[1]
        if key_node then
          local key_text = vim.treesitter.get_node_text(key_node, buf)
          local _, _, end_row, end_col = key_node:range()

          local value = dataset.translations[key_text]
          local virt_text = value or ("⚠ " .. key_text)
          local hl = value and M.opts.highlight or "DiagnosticWarn"

          local line = vim.api.nvim_buf_get_lines(buf, end_row, end_row + 1, false)[1] or ""
          local col = math.min(end_col + 1, #line)

          vim.api.nvim_buf_set_extmark(buf, ns, end_row, col, {
            virt_text = { { virt_text, hl } },
            hl_mode = "combine",
            spell = true,
          })
        end
      end
    end
  end
end

--- Recompute marks of a line range. Called on edits, never on redraw.
--- Without a range the whole buffer is decorated (buffer attach, reload).
local function decorate(buf, first, last)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
    return
  end

  if not M.opts.active[vim.bo[buf].filetype] then
    return
  end

  local line_count = vim.api.nvim_buf_line_count(buf)
  first = math.max(first or 0, 0)
  -- One line of margin: replacing a line can move its extmarks onto the next line
  last = math.min((last or line_count) + 1, line_count)
  if first >= last then
    return
  end

  -- Clear one more line than decorated: collapsed marks may end up one past the range
  vim.api.nvim_buf_clear_namespace(buf, ns, first, math.min(last + 1, line_count + 1))

  local dataset = dataset_for(buf)
  if not dataset then
    return
  end

  local parser_ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not parser_ok or not parser then
    return
  end

  local trees = parsed_trees(parser, first, last)
  if not next(trees) then
    return
  end

  for lang, tree in pairs(trees) do
    local parsed_ok, parsed = pcall(tree.parse, tree, { first, last })
    if parsed_ok then
      for _, tstree in ipairs(parsed) do
        decorate_tree(tstree, lang, buf, dataset, first, last)
      end
    end
  end
end

local FULL_BUFFER = math.huge

local function schedule_decorate(buf, first, last)
  local range = pending[buf]
  if range then
    range.first = math.min(range.first, first or 0)
    range.last = math.max(range.last, last or FULL_BUFFER)
    return
  end

  pending[buf] = { first = first or 0, last = last or FULL_BUFFER }
  vim.schedule(function()
    local pending_range = pending[buf]
    pending[buf] = nil
    if pending_range then
      decorate(buf, pending_range.first, pending_range.last)
    end
  end)
end

local function attach(buf)
  if not vim.api.nvim_buf_is_loaded(buf) then
    return
  end

  if not M.opts.active[vim.bo[buf].filetype] then
    return
  end

  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function(_, _, _, first, last_old, last_new)
      schedule_decorate(buf, first, math.max(last_old, last_new) + 1)
    end,
    on_reload = function()
      schedule_decorate(buf)
    end,
    on_detach = function()
      pending[buf] = nil
    end,
  })

  decorate(buf)
end

local function reload(repo)
  for key in pairs(datasets) do
    if repo == nil or key:sub(1, #repo + 2) == repo .. "::" then
      datasets[key] = nil
    end
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      decorate(buf)
    end
  end
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
  local indent = lines[insert_line + 1] and lines[insert_line + 1]:match("^(%s*)") or nil
  if indent == nil then
    indent = "  "
  end

  local new_line = indent .. '"' .. key .. '": ' .. vim.json.encode(value) .. ","

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

local function makefile_ui(root)
  local ok, lines = pcall(vim.fn.readfile, root .. "/Makefile")
  if not ok then
    return nil
  end

  for _, line in ipairs(lines) do
    local ui = line:match("^UI=([%w%-%./]+)")
    if ui then
      return ui
    end
  end

  return nil
end

--- Where a new key of this buffer should be added
local function primary_file(buf)
  local name = M.opts.translation_file

  -- Regular service: <service>/src/i18n/en_DEV.json
  local service = vim.fs.root(buf, "service.yaml")
  if service then
    local path = vim.fs.normalize(service) .. "/src/i18n/" .. name
    if vim.uv.fs_stat(path) then
      return path
    end
  end

  -- System tests: derive the tested UI service from UI=... in the Makefile
  local makefile_root = vim.fs.root(buf, "Makefile")
  if makefile_root then
    local ui = makefile_ui(makefile_root)
    if ui then
      local path = repo_root(buf) .. "/domains/" .. ui .. "/src/i18n/" .. name
      if vim.uv.fs_stat(path) then
        return path
      end
    end
  end

  return nil
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

  local parser_ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not parser_ok or not parser then
    error("No treesitter parser available")
    return nil
  end

  local line_count = vim.api.nvim_buf_line_count(buf)

  for lang, tree in pairs(parsed_trees(parser, 0, line_count)) do
    local query = queries[lang]
    local parsed_ok, parsed = pcall(tree.parse, tree, { 0, line_count })
    if parsed_ok then
      for _, tstree in ipairs(parsed) do
        local matched, matches = pcall(query.iter_matches, query, tstree:root(), buf)
        if matched then
          for _, match in matches do
            for id, nodes in pairs(match) do
              if query.captures[id] == "translation.key" then
                local key_node = nodes[1]
                if key_node then
                  local start_row, start_col, end_row, end_col = key_node:range()
                  if start_row == row and col >= start_col and col <= end_col then
                    return vim.treesitter.get_node_text(key_node, buf)
                  end
                end
              end
            end
          end
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

  local buf = vim.api.nvim_get_current_buf()
  local dataset = dataset_for(buf)

  local location = dataset and dataset.locations[key]
  if location then
    vim.cmd.edit(vim.fn.fnameescape(location.file))
    vim.api.nvim_win_set_cursor(0, { location.line or 1, 0 })
    return
  end

  -- Key not found, ask user for value
  local json_file = primary_file(buf)
  if not json_file then
    error("No writable translation file found for this buffer")
    return
  end

  vim.ui.input({ prompt = "Enter value for '" .. key .. "': " }, function(value)
    if value and value ~= "" then
      if add_key_to_json(json_file, key, value) then
        reload(nil)
      end
    end
  end)
end

local function active_filetypes()
  local filetypes = {}
  for filetype, enabled in pairs(M.opts.active) do
    if enabled then
      filetypes[#filetypes + 1] = filetype
    end
  end
  return table.concat(filetypes, ",")
end

M.init = function()
  build_queries()

  if not initialized then
    initialized = true

    vim.api.nvim_create_autocmd("FileType", {
      pattern = active_filetypes(),
      callback = function(args)
        attach(args.buf)
      end,
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*" .. M.opts.translation_file,
      callback = function(args)
        reload(repo_root(args.buf))
      end,
    })

    vim.api.nvim_create_user_command("TranslationsReload", function()
      reload(nil)
    end, { desc = "Reload translation data and redraw marks" })
  end

  -- Buffers that were opened before setup (their FileType event is already gone)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      attach(buf)
    end
  end

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
