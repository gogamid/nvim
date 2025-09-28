local M = {}
local ns_id = vim.api.nvim_create_namespace("bionic_read")

local function setup_highlights()
  vim.api.nvim_set_hl(0, "BionicPrefix", { bold = true, default = true })
end

local function is_word_char(char)
  return char:match("[%w']") ~= nil
end

local function highlight_word_prefix(line_number, word_start, word_length)
  local prefix_length = vim.g.bionic_prefix_length or 2
  if word_length >= prefix_length then
    vim.api.nvim_buf_set_extmark(0, ns_id, line_number, word_start - 1, {
      hl_group = "BionicPrefix",
      end_col = word_start - 1 + prefix_length,
      priority = 100,
    })
  end
end

local function process_line_words(line_text, line_number)
  local line_length = #line_text
  local word_start = nil

  for col = 1, line_length do
    local current_char = line_text:sub(col, col)
    local is_word = is_word_char(current_char)

    if word_start then
      local is_end_of_line = (col == line_length)
      local is_end_of_word = not is_word or (is_end_of_line and is_word)

      if is_end_of_word then
        local word_end = is_end_of_line and is_word and col or col - 1
        local word_length = word_end - word_start + 1
        highlight_word_prefix(line_number, word_start, word_length)
        word_start = nil
      end
    elseif is_word then
      word_start = col
    end
  end
end

local function apply_bionic_highlighting()
  vim.b.bionic_on = true
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

  local total_lines = vim.api.nvim_buf_line_count(0)
  local lines = vim.api.nvim_buf_get_lines(0, 0, total_lines, true)

  for line_index, line_text in ipairs(lines) do
    process_line_words(line_text, line_index - 1)
  end
end

local function clear_bionic_highlighting()
  vim.b.bionic_on = false
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

local function should_auto_activate_for_filetype()
  local filetypes = vim.g.bionic_filetypes or {}
  return vim.tbl_isempty(filetypes) or vim.tbl_contains(filetypes, vim.bo.filetype)
end

local function toggle_bionic_read()
  if vim.b.bionic_on == nil then
    vim.b.bionic_on = false
  end

  if vim.b.bionic_on then
    clear_bionic_highlighting()
  else
    apply_bionic_highlighting()
  end
end

M.setup = function(opts)
  opts = opts or {}
  vim.g.bionic_prefix_length = opts.prefix_length or 2
  vim.g.bionic_auto_activate = opts.auto_activate ~= nil and opts.auto_activate or false
  vim.g.bionic_filetypes = opts.filetypes or {}

  setup_highlights()

  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = setup_highlights,
  })

  if vim.g.bionic_auto_activate then
    vim.api.nvim_create_autocmd("BufReadPost", {
      callback = function()
        if vim.b.bionic_on == nil then
          vim.b.bionic_on = false
        end
        if not vim.b.bionic_on and should_auto_activate_for_filetype() then
          apply_bionic_highlighting()
        end
      end,
    })
  end

  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave" }, {
    callback = function()
      if vim.b.bionic_on then
        apply_bionic_highlighting()
      end
    end,
  })
end

M.toggle = toggle_bionic_read

vim.api.nvim_create_user_command("BionicToggle", toggle_bionic_read, { range = 2 })

return M
