local M = {}

local BYTES_LIMIT = 6000
local MAX_CONCURRENT = 3
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

-- [Helper] Appends the import to the current buffer
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

  -- Find insertion point logic
  local import_start, import_end, package_line = nil, nil, nil
  for i, line in ipairs(lines) do
    if line:match("^import %($") then
      import_start = i
    elseif import_start and line:match("^%)$") then
      import_end = i - 1
      break
    elseif line:match("^package ") then
      package_line = i
    end
  end

  if import_start and import_end then
    vim.api.nvim_buf_set_lines(bufnr, import_end, import_end, false, { "\t" .. import_line })
    info("added import at the bottom: " .. alias)
  elseif import_start then
    vim.api.nvim_buf_set_lines(bufnr, import_start, import_start, false, { "\t" .. import_line })
    info("added import at the top: " .. alias)
  elseif package_line then
    local new_block = { "", "import (", "\t" .. import_line, ")" }
    vim.api.nvim_buf_set_lines(bufnr, package_line, package_line, false, new_block)
    info("added import after package: " .. alias)
  end
end

-- [Helper] Creates Luasnip snippets from the gathered imports
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

-- [Helper] Parses text content to find imports
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

-- [Worker] Processes a single file asynchronously
-- Calls 'done_cb(extracted_imports_or_nil)' when finished
local function read_and_parse_file(file, seen_triggers, done_cb)
  uv.fs_open(file, "r", 438, function(err, fd)
    if err then
      return done_cb(nil)
    end

    uv.fs_fstat(fd, function(stat_err, stat)
      if stat_err then
        uv.fs_close(fd)
        return done_cb(nil)
      end

      local size = stat.size > BYTES_LIMIT and BYTES_LIMIT or stat.size

      uv.fs_read(fd, size, 0, function(read_err, data)
        uv.fs_close(fd) -- Always close file descriptor

        if not read_err and data then
          -- Parse logic (Cpu bound, but fast enough for this context)
          local imports = extract_imports(data, seen_triggers)
          done_cb(imports)
        else
          done_cb(nil)
        end
      end)
    end)
  end)
end

-- [Orchestrator] The Worker Pool Logic
local function process_files(files)
  local all_imports = {}
  local seen_triggers = {} -- Shared state to avoid duplicates across files

  local file_index = 1
  local active_workers = 0
  local processed_count = 0
  local total_files = #files

  -- The recursive scheduler
  local function schedule_next()
    -- 1. Check if completely finished
    if processed_count == total_files then
      -- Must wrap final UI update in schedule
      vim.schedule(function()
        create_snippets(all_imports)
      end)
      return
    end

    -- 2. Fill the worker slots up to MAX_CONCURRENT
    while active_workers < MAX_CONCURRENT and file_index <= total_files do
      local current_file = files[file_index]
      file_index = file_index + 1
      active_workers = active_workers + 1

      -- Run the job
      read_and_parse_file(current_file, seen_triggers, function(new_imports)
        -- Collect results (Lua is single threaded, so this append is safe)
        if new_imports then
          vim.list_extend(all_imports, new_imports)
        end

        -- Worker finished
        active_workers = active_workers - 1
        processed_count = processed_count + 1

        -- Trigger next job immediately
        schedule_next()
      end)
    end
  end

  -- Start the machine
  schedule_next()
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

    info("Found " .. #files .. " files. Parsing...")
    process_files(files)
  end)
end

return M
