local M = {}

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

local function process_files(files)
  local imports = {}
  local seen_triggers = {}
  local files_processed = 0

  -- Process each service.go file
  for _, file in ipairs(files) do
    vim.uv.fs_open(file, "r", 438, function(err, fd)
      if err then
        files_processed = files_processed + 1
        return
      end

      vim.uv.fs_fstat(fd, function(stat_err, stat)
        if stat_err then
          vim.uv.fs_close(fd)
          files_processed = files_processed + 1
          return
        end

        vim.uv.fs_read(fd, stat.size, 0, function(read_err, data)
          vim.uv.fs_close(fd)

          if not read_err and data then
            local lines = vim.split(data, "\n")
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
