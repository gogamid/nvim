-- Bionic Read: keep syntax highlighting and make first two letters bold
local M = {}
local ns_id = vim.api.nvim_create_namespace("bionic_read")

local function set_highlights()
   vim.api.nvim_set_hl(0, "BionicPrefix", {bold = true, default = true})
end

set_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
   pattern = "*",
   callback = set_highlights,
})

local function create()
   vim.b.bionic_on = true
   local line_start = 0
  local line_end = vim.api.nvim_buf_line_count(0)
  local lines = vim.api.nvim_buf_get_lines(0, line_start, line_end, true)
  local i = line_start - 1
  for _, line in pairs(lines) do
    local len = #line
    i = i + 1

    local st = nil
    for j = 1, len do
      local cur = string.sub(line, j, j)
      local re = cur:match("[%w']+")
      if st then
        if j == len then
          if re then
            j = j + 1
            re = nil
          end
        end
        if not re then
          local en = j - 1
          local word_len = en - st + 1
          if word_len >= vim.g.bionic_prefix_length then
            vim.api.nvim_buf_set_extmark(0, ns_id, i, st - 1, {
              hl_group = "BionicPrefix",
              end_col = st - 1 + vim.g.bionic_prefix_length,
              priority = 100,
            })
          end
          st = nil
        end
      elseif re then
        st = j
      end
    end
  end
end

local function clear()
   vim.b.bionic_on = false
   vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
   ns_id = vim.api.nvim_create_namespace("bionic_read")
end

M.setup = function(opts)
   opts = opts or {}
   vim.g.bionic_prefix_length = opts.prefix_length or 2
   vim.g.bionic_auto_activate = opts.auto_activate ~= nil and opts.auto_activate or false
   vim.g.bionic_filetypes = opts.filetypes or {}

   if vim.g.bionic_auto_activate then
      vim.api.nvim_create_autocmd("BufReadPost", {
         callback = function()
            if vim.b.bionic_on == nil then
               vim.b.bionic_on = false
            end
            if not vim.b.bionic_on then
               if vim.tbl_isempty(vim.g.bionic_filetypes) or vim.tbl_contains(vim.g.bionic_filetypes, vim.bo.filetype) then
                  create()
               end
            end
         end,
      })
   end
end

local toggleBionicRead = function()
   if vim.b.bionic_on == nil then
      vim.b.bionic_on = false
   end
   local on = vim.b.bionic_on
   on = not on
   if on then
     create()
   else
     clear()
   end
end

M.toggleBionicRead = toggleBionicRead

vim.api.nvim_create_user_command("BionicToggle", toggleBionicRead, {range = 2})

return M
