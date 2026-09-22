local M = {}

local state_file = vim.fn.stdpath("state") .. "/task_env.json"
local base_env = {}

local function read_overrides()
  local fp = io.open(state_file, "r")
  if not fp then
    return {}
  end
  local content = fp:read("*a")
  fp:close()
  local ok, decoded = pcall(vim.json.decode, content)
  if not ok or type(decoded) ~= "table" then
    return {}
  end
  return decoded
end

local function write_overrides(overrides)
  local fp = io.open(state_file, "w")
  if not fp then
    vim.notify("Cannot write " .. state_file, vim.log.levels.ERROR)
    return
  end
  fp:write(next(overrides) == nil and "{}" or vim.json.encode(overrides))
  fp:close()
end

function M.overrides()
  return read_overrides()
end

function M.set(name, value)
  local overrides = read_overrides()
  overrides[name] = value
  write_overrides(overrides)
  vim.env[name] = value
  vim.notify(string.format("%s=%s", name, value))
end

function M.unset(name)
  local overrides = read_overrides()
  overrides[name] = nil
  write_overrides(overrides)
  vim.env[name] = base_env[name]
  vim.notify(string.format("Unset %s", name))
end

function M.setup()
  base_env = vim.fn.environ()
  for name, value in pairs(read_overrides()) do
    if type(value) == "string" then
      vim.env[name] = value
    end
  end
end

function M.items()
  local overrides = read_overrides()
  local seen = {}
  local items = {}

  local function add(name, value, overridden)
    if seen[name] then
      return
    end
    seen[name] = true
    value = tostring(value or "")
    items[#items + 1] = {
      text = name .. " = " .. value,
      name = name,
      value = value,
      overridden = overridden,
      preview = { text = name .. "=" .. value, ft = "sh" },
    }
  end

  local override_names = vim.tbl_keys(overrides)
  table.sort(override_names)
  for _, name in ipairs(override_names) do
    add(name, overrides[name], true)
  end

  local env = vim.fn.environ()
  local env_names = vim.tbl_keys(env)
  table.sort(env_names)
  for _, name in ipairs(env_names) do
    add(name, env[name], false)
  end

  return items
end

local function edit(name, current)
  Snacks.input({ prompt = name .. "=", default = current }, function(value)
    if value == nil then
      return
    end
    M.set(name, value)
  end)
end

function M.picker()
  Snacks.picker.pick({
    title = "Env Variables",
    finder = M.items,
    format = function(item)
      return {
        { item.name, item.overridden and "SnacksPickerDir" or "SnacksPickerFile" },
        { " = ", "SnacksPickerComment" },
        { item.value, "SnacksPickerComment" },
      }
    end,
    confirm = "env_edit",
    actions = {
      env_edit = function(picker)
        local item = picker:current()
        if not item then
          return
        end
        picker:close()
        edit(item.name, vim.env[item.name] or item.value)
      end,
      env_new = function(picker)
        picker:close()
        Snacks.input({ prompt = "Variable name: " }, function(name)
          if name == nil or name == "" then
            return
          end
          edit(name, vim.env[name] or "")
        end)
      end,
      env_unset = function(picker)
        local item = picker:current()
        if not item or not item.overridden then
          return
        end
        M.unset(item.name)
        picker:find()
      end,
    },
    win = {
      input = {
        keys = {
          ["<C-o>"] = { "env_new", desc = "New variable", mode = { "n", "i" } },
          ["<C-x>"] = { "env_unset", desc = "Unset override", mode = { "n", "i" } },
        },
      },
    },
  })
end

return M
