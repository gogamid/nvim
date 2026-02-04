local function root()
  local path = vim.g.root
  path = vim.fn.fnamemodify(path, ":~")
  if #path > 50 then
    local parts = vim.fn.split(path, "/")
    if #parts >= 4 then
      local first_two = parts[1] .. "/" .. parts[2]
      local last_two = parts[#parts - 1] .. "/" .. parts[#parts]
      path = first_two .. "/../" .. last_two
    end
  end
  return path
end

local function supermaven()
  local icon = vim.g.icons_enabled and " " or "smvn"
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
  local icon = vim.g.icons_enabled and "󰉶 " or "fmt:"

  local formatters, use_lsp = require("conform").list_formatters_to_run(0)
  local names = {}
  for i, formatter_info in ipairs(formatters) do
    names[i] = formatter_info.name
  end
  local lsp = use_lsp and " + LSP" or ""

  return icon .. table.concat(names, ", ") .. lsp
end

local function lsp()
  local icon = vim.g.icons_enabled and " " or "lsp:"

  local client_names = {}
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    table.insert(client_names, client.name)
  end

  return icon .. table.concat(client_names, ", ")
end

local function ftype()
  local icon = vim.g.icons_enabled and " " or "ft:"
  local ft = vim.bo.filetype
  return icon .. ft
end

local function pomodoro()
  return {
    require("modules.pomodoro").status,
    color = function()
      local c = require("modules.pomodoro").status_color()
      return c
    end,
  }
end

return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      globalstatus = true,
      component_separators = { left = "|", right = "|" },
    },
    sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {
        "filename",
        root,
        "%=",
        -- pomodoro(),
      },
      lualine_x = {
        supermaven,
        "overseer",
        overseer_status,
        "diagnostics",
        "diff",
        "progress",
        ftype,
        formatter,
        lsp,
      },
      lualine_y = {},
      lualine_z = {},
    },
  },
}
