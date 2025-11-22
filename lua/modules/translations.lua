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

local query_by_ft = {
  typescript = ts_translation_query,
  vue = ts_translation_query,
  go = go_translation_query,
}

local lang_by_ft = {
  typescript = "typescript",
  vue = "typescript",
  go = "go",
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

local function on_win(_, win, buf, top, bottom)
  local filetype = vim.bo[buf].filetype

  if query_by_ft[filetype] == nil then
    return false
  end

  vim.api.nvim_buf_clear_namespace(buf, ns, top, bottom)

  -- For Vue files, get the injected TypeScript parser
  -- local parser
  -- if filetype == "vue" then
  --   local lang_parser = vim.treesitter.get_parser(buf, "typescript")
  --   parser = lang_parser and lang_parser:children().typescript or lang_parser
  -- else
  --   parser = vim.treesitter.get_parser(buf, filetype)
  -- end

  local parser = vim.treesitter.get_parser(buf, lang_by_ft[filetype])
  if not parser then
    return false
  end

  local trees = parser:parse()
  local tree = trees and trees[1]
  if not tree then
    return false
  end

  -- Load translations once per window render, todo: maybe autocommand when we open buffer?
  local json_file = vim.fn.findfile("en_DEV.json")
  local translations = load_translations(json_file)

  local query = vim.treesitter.query.parse(lang_by_ft[filetype], query_by_ft[filetype])
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

M.init = function()
  vim.api.nvim_set_decoration_provider(ns, { on_win = on_win })
end

local default_opts = {}

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("keep", opts or {}, default_opts)
  M.init()
end

return M
