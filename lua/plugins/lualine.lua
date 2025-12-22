-- local is_ssh = os.getenv("SSH_CONNECTION") ~= nil or os.getenv("TERM_PROGRAM") == "Termius"
local is_ssh = false --webssh supports icons

local function supermaven()
  local icon = is_ssh and "smvn" or " "
  return require("supermaven-nvim.api").is_running() and icon or ""
end

local function overseer_status()
  local ok, overseer = pcall(require, "overseer")
  if not ok then
    return ""
  end

  local tasks = overseer.list_tasks({ status = "RUNNING" })
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

local function formatter()
  local icon = is_ssh and "fmt:" or "󰉶 "

  local formatters, use_lsp = require("conform").list_formatters_to_run(0)
  local names = {}
  for i, formatter_info in ipairs(formatters) do
    names[i] = formatter_info.name
  end
  local lsp = use_lsp and " + LSP" or ""

  return icon .. table.concat(names, ", ") .. lsp
end

local function lsp()
  local icon = is_ssh and "lsp:" or " "

  local client_names = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    table.insert(client_names, client.name)
  end

  return icon .. table.concat(client_names, ", ")
end

local function ftype()
  local ft_icon = " "
  local icon = is_ssh and "ft:" or ft_icon
  local ft = vim.bo.filetype
  return icon .. ft
end

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "auto", -- Use your current colorscheme's theme or set a specific one
        globalstatus = true, -- Use a single statusline for all windows
        icons_enabled = not is_ssh,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
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
          ftype,
          formatter,
          lsp,
          "%=",
          {
            require("modules.pomodoro").status,
            color = function()
              local c = require("modules.pomodoro").status_color()
              return c
            end,
          },
        },
        -- "location"
        -- - `branch` (git branch)
        -- - `buffers` (shows currently available buffers)
        -- - `diagnostics` (diagnostics count from your preferred source)
        -- - `diff` (git diff status)
        -- - `encoding` (file encoding)
        -- - `fileformat` (file format)
        -- - `filename`
        -- - `filesize`
        -- - `filetype`
        -- - `hostname`
        -- - `location` (location in file in line:column format)
        -- - `mode` (vim mode)
        -- - `progress` (%progress in file)
        -- - `searchcount` (number of search matches when hlsearch is active)
        -- - `selectioncount` (number of selected characters or lines)
        -- - `tabs` (shows currently available tabs)
        -- - `windows` (shows currently available windows)
        -- - `lsp_status` (shows active LSPs in the current buffer and a progress spinner)
        lualine_x = { supermaven, "overseer", overseer_status, "diagnostics", "diff", "progress" },
        lualine_y = {},
        lualine_z = {},
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        -- lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {
        -- lualine_a = {},
        -- lualine_b = {},
        -- lualine_c = {},
        -- lualine_x = { "filename" },
        -- lualine_y = {},
        -- lualine_z = {},
      },
      winbar = {
        -- lualine_a = {},
        -- lualine_b = {},
        -- lualine_c = { "filename" },
        -- lualine_x = {},
        -- lualine_y = {},
        -- lualine_z = {},
      },
      inactive_winbar = {},
      extensions = {},
    },
  },
  {
    "b0o/incline.nvim",
    config = function()
      require("incline").setup()
    end,
    -- Optional: Lazy load Incline
    event = "VeryLazy",
  },
}
