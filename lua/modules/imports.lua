local M = {}

local BYTES_LIMIT = 6000
local uv = vim.uv
local fname = "imports.lua"

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

local function append_import(package_path, alias)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local import_line = string.format('%s "%s"', alias, package_path)

  for _, line in ipairs(lines) do
    if line:find('"' .. package_path .. '"', 1, true) then
      info("import already exists: " .. alias)
      return
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
    vim.api.nvim_buf_set_lines(bufnr, import_end, import_end, false, { "\t" .. import_line })
    info("added import at the bottom: " .. alias)
  elseif package_line then
    local new_block = { "", "import (", "\t" .. import_line, ")" }
    vim.api.nvim_buf_set_lines(bufnr, package_line, package_line, false, new_block)
    info("added import after package: " .. alias)
  end
end

local function create_snippets(imports)
  local ls = require("luasnip")
  local events = require("luasnip.util.events")

  local snippets = {}
  for _, import in ipairs(imports) do
    table.insert(
      snippets,
      ls.snippet(import.trigger, {
        ls.text_node(import.alias),
        ls.insert_node(0, "", {
          node_callbacks = {
            [events.enter] = function()
              append_import(import.package_path, import.alias)
            end,
          },
        }),
      })
    )
  end

  if #snippets > 0 then
    ls.add_snippets("go", snippets, { key = "go_imports_dynamic" })
    info("added " .. #snippets .. " import snippets")
  else
    error("no imports found")
  end
end

local function extract_imports(data, seen_triggers)
  local new_imports = {}
  local in_import_block = false

  local lines = vim.split(data, "\n")
  for _, line in ipairs(lines) do
    local trimmed = vim.trim(line)

    if trimmed:match("^import%s*%(") then
      in_import_block = true
    elseif in_import_block and trimmed == ")" then
      in_import_block = false
    elseif in_import_block and trimmed:match('^%w+%s+"') then
      local alias, package_path = trimmed:match('^(%w+)%s+"([^"]+)"')
      if alias and package_path and not seen_triggers[alias] then
        seen_triggers[alias] = true
        table.insert(new_imports, {
          trigger = alias,
          alias = alias,
          package_path = package_path,
        })
      end
    end
  end
  return new_imports
end

local function process_files(files)
  local imports = {}
  local seen_triggers = {}
  local files_processed = 0

  for _, file in ipairs(files) do
    uv.fs_open(file, "r", 438, function(err, fd)
      if err then
        files_processed = files_processed + 1
        return
      end

      uv.fs_fstat(fd, function(stat_err, stat)
        if stat_err then
          uv.fs_close(fd)
          files_processed = files_processed + 1
          return
        end

        local size = stat.size > BYTES_LIMIT and BYTES_LIMIT or stat.size

        uv.fs_read(fd, size, 0, function(read_err, data)
          uv.fs_close(fd)

          if not read_err and data then
            local new_imports = extract_imports(data, seen_triggers)
            vim.list_extend(imports, new_imports)
          end

          files_processed = files_processed + 1

          -- When all files are processed, create snippets
          if files_processed == #files then
            vim.schedule(function()
              create_snippets(imports)
            end)
          end
        end)
      end)
    end)
  end
end

function M.add_snippets()
  local git_root = vim.fs.root(0, { ".git" })
  if git_root == nil then
    error("git root not found")
    return
  end

  local target_file = "service.go"
  local shell_cmd = { "find", git_root, "-name", target_file, "-type", "f" }
  vim.system(shell_cmd, { text = true }, function(out)
    if out.code ~= 0 then
      error("command err " .. out.stderr)
      return
    end

    local files = vim.split(vim.trim(out.stdout), "\n", { trimempty = true })
    if #files == 0 then
      error("no files found")
      return
    end

    process_files(files)
  end)
end

return M
