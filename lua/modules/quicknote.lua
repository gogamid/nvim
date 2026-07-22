local M = {}

local scratchpad_dir = vim.env.GLOBAL_NOTE_PATH
local notes_file = vim.env.QUICKNOTE_FILE
  or (scratchpad_dir and scratchpad_dir .. "/Scratchpad.md")
  or "/tmp/quick-notes.md"

function M.collect()
  -- Must be called from visual mode
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\x16" then
    vim.notify("QuickNote: requires visual selection", vim.log.levels.WARN)
    return
  end

  -- Get selection range using visual marks (v=start, .=end)
  local line_a = vim.fn.line("v")
  local line_b = vim.fn.line(".")
  local start_line = math.min(line_a, line_b)
  local end_line = math.max(line_a, line_b)
  local abs_path = vim.fn.expand("%:p")

  -- Get visually selected text
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
  local selected_text = table.concat(lines, "\n")

  -- Ask for user note
  vim.ui.input({ prompt = "Note: " }, function(comment)
    if not comment or comment == "" then
      return
    end

    local ft = vim.bo.filetype
    if ft == "" then
      ft = "text"
    end

    local entry_lines = {}
    table.insert(entry_lines, "## " .. abs_path .. ":" .. start_line .. "-" .. end_line)
    table.insert(entry_lines, "")
    table.insert(entry_lines, "```" .. ft)
    table.insert(entry_lines, selected_text)
    table.insert(entry_lines, "```")
    table.insert(entry_lines, "")
    table.insert(entry_lines, comment)
    table.insert(entry_lines, "")
    table.insert(entry_lines, "")

    local content = table.concat(entry_lines, "\n")

    local ok, err = pcall(function()
      local fd = io.open(notes_file, "a")
      if not fd then
        error("could not open file for writing")
      end
      fd:write(content)
      fd:close()
    end)

    if ok then
      vim.notify("QuickNote saved to " .. notes_file)
    else
      vim.notify("QuickNote: " .. tostring(err), vim.log.levels.ERROR)
    end
  end)
end

return M
