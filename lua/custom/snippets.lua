-- lua/config/snippets.lua

-- Make sure luasnip is loaded
local ls = require("luasnip")
local s = ls.s
local i = ls.i
local t = ls.t
local f = ls.f

--[[
 A helper function to intelligently add a Go import.
 It checks if the import already exists and finds the correct place to insert it.
 ]]
local function add_go_import(package_path, alias)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local full_import_str = string.format('%s "%s"', alias, package_path)

  -- 1. Check if the import already exists to avoid duplicates
  for _, line in ipairs(lines) do
    if line:match('"' .. package_path:gsub("%-", "%%-") .. '"') then
      -- Import already exists, do nothing.
      return
    end
  end

  -- 2. Find where to insert the new import
  local import_block_start = -1
  local package_line = -1
  for i, line in ipairs(lines) do
    if line:match("^import %($") then
      import_block_start = i -- Found the start of an import() block
      break
    end
    if line:match("^package ") then
      package_line = i -- Found the package declaration
    end
  end

  local new_import_line = "\t" .. full_import_str

  if import_block_start > 0 then
    -- Case A: An import block `import (...)` already exists. Insert the line inside it.
    vim.api.nvim_buf_set_lines(bufnr, import_block_start, import_block_start, false, { new_import_line })
  elseif package_line > 0 then
    -- Case B: No import block, but a `package` line was found. Create a new block.
    local new_block = {
      "",
      "import (",
      new_import_line,
      ")",
    }
    vim.api.nvim_buf_set_lines(bufnr, package_line, package_line, false, new_block)
  end
  -- If neither is found, we don't do anything, which is a safe fallback.
end

--[[
 This function creates a Go Protobuf snippet.
 - trigger: The shortcut you type (e.g., "pbs1")
 - alias: The package alias (e.g., "pbService1")
 - package_path: The full import path
 ]]
local function create_proto_snippet(trigger, alias, package_path)
  return s(trigger, {
    -- 1. Insert the alias and a dot, followed by a placeholder to type the method name
    t(alias .. "."),
    i(1),
    -- 2. Run our function as a side-effect to add the import.
    -- This function node returns an empty string so it doesn't add text at the cursor.
    f(function()
      add_go_import(package_path, alias)
      return ""
    end),
  })
end

-- Define your snippets here
local go_snippets = {
  create_proto_snippet("pbdate", "pbDate", "google.golang.org/genproto/googleapis/type/date"),
  create_proto_snippet(
    "policies",
    "policies",
    "dev.azure.com/schwarzit/lidl.wawi-core/domains/wam/policies/definition/proto"
  ),
}

-- Add the snippets to luasnip for the 'go' filetype
ls.add_snippets("go", go_snippets)
