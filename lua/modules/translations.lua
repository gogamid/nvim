local M = {}

local ns = vim.api.nvim_create_namespace("translations")

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

local active = {
  typescript = true,
  vue = true,
  go = true,
}

local highlight = "Conceal"

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
            virt_text = { { " → " .. value, highlight } },
            virt_text_pos = "inline",
          })
        end
      end
    end
  end
end

local function on_win(_, win, buf, top, bottom)
  local filetype = vim.bo[buf].filetype
  if not active[filetype] then
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

  local translations = load_translations(vim.fn.findfile("en_DEV.json"))

  for lang, ltree in pairs(ltrees) do
    local tstrees = ltree:parse({ top, bottom + 1 })
    if tstrees then
      handle_trees(tstrees, lang, buf, top, bottom + 1, translations)
    end
  end

  return true
end

M.init = function()
  vim.api.nvim_set_decoration_provider(ns, { on_win = on_win })
end

local default_opts = {}

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("keep", opts or {}, default_opts)
  M.init()
end

return M
