local function supermaven()
  if require("supermaven-nvim.api").is_running() then
    return " "
  else
    return " "
  end
end

local function overseer_status()
  local ok, overseer = pcall(require, "overseer")
  if not ok then return "" end

  local tasks = overseer.list_tasks({status = "RUNNING"})
  if #tasks > 0 then
    local task_names = {}
    for _, task in ipairs(tasks) do
      -- Extract meaningful part of task name
      local name = task.name or "unknown"
      -- Shorten common patterns
      name = name:gsub("^test%-line: ", "🧪 ")
      name = name:gsub("^test%-file: ", "📁 ")
      name = name:gsub("^make ", "🔨 ")
      table.insert(task_names, name)
    end
    return " " .. table.concat(task_names, " | ")
  end
  return ""
end

local function formatter_status()
  --get bufnr
  local bufnr = vim.api.nvim_get_current_buf()
  local formatters, use_lsp = require("conform").list_formatters_to_run(bufnr)

  if #formatters > 0 then
    local formatter_names = {}
    for _, formatter_info in ipairs(formatters) do
      table.insert(formatter_names, formatter_info.name)
    end
    local result = "󰉶 " .. table.concat(formatter_names, ", ")
    if use_lsp then
      result = result .. " + LSP"
    end
    return result
  elseif use_lsp then
    return "󰉶 LSP"
  else
    return "󰉶 "
  end
end

return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "everforest", -- Use your current colorscheme's theme or set a specific one
      globalstatus = true,  -- Use a single statusline for all windows
      icons_enabled = true,
      component_separators = {left = "", right = ""},
      section_separators = {left = "", right = ""},
      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = true,
      always_show_tabline = true,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
        refresh_time = 16, -- ~60fps
        events = {
          "WinEnter",
          "BufEnter",
          "BufWritePost",
          "SessionLoadPost",
          "FileChangedShellPost",
          "VimResized",
          "Filetype",
          "CursorMoved",
          "CursorMovedI",
          "ModeChanged",
          "User OverseerTaskUpdate", -- Custom event for overseer updates
        },
      },
    },
    sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        "filetype",
        formatter_status,
        "lsp_status",
        "%=",
        {
          "filename",
          path = 3,
          fmt = function(str)
            local max = 60
            if #str < max then
              return str .. string.rep(" ", max - #str)
            elseif #str > max then
              return "..." .. str:sub(-max)
            else
              return str
            end
          end,
        },
      },
      lualine_x = {supermaven, "overseer", overseer_status, "diagnostics", "diff", "progress"},
      lualine_y = {},
      lualine_z = {},
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {"filename"},
      lualine_x = {"location"},
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {},
  },
}
