local M = {}

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

function M.compute_and_add_alias_import_snippets()
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
          [e.enter] = function() add_import_to_go_file_if_not_exists(package_path, alias) end,
        },
      }),
    })
  end

  -- Find git root directory asynchronously
  vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify("Not in a git repository", vim.log.levels.ERROR)
      end)
      return
    end

    local git_root = vim.trim(result.stdout)

    -- Find all service.go files asynchronously
    vim.system({ "find", git_root, "-name", "service.go", "-type", "f" }, { text = true }, function(find_result)
      if find_result.code ~= 0 then
        vim.schedule(function()
          vim.notify("Failed to find service.go files", vim.log.levels.ERROR)
        end)
        return
      end

      local service_files = vim.split(vim.trim(find_result.stdout), "\n", { trimempty = true })
      if #service_files == 0 then
        vim.schedule(function()
          vim.notify("No service.go files found", vim.log.levels.WARN)
        end)
        return
      end

      local imports = {}
      local seen_triggers = {}
      local files_processed = 0

      -- Process each service.go file
      for _, file in ipairs(service_files) do
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
              if files_processed == #service_files then
                vim.schedule(function()
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
                end)
              end
            end)
          end)
        end)
      end
    end)
  end)
end

return M
