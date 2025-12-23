local api = vim.api
local actions = {
  resume = "Resume Pomodoro",
  stop = "Stop Pomodoro",
  short_break = "Short Break",
  long_break = "Long break",
  work = "Work",
  stats = "Stats",
  change_task_name = "Change Task Name",
}

local phase = {
  UNKNOWN = "",
  WORK = "work",
  BREAK = "break",
  LONG_BREAK = "long break",
}

local default_task_name = "focus"

local opts = {
  -- work_interval = 25 * 60,
  -- break_interval = 5 * 60,
  -- long_interval = 15 * 60,
  work_interval = 25,
  break_interval = 5,
  long_interval = 15,
  count = 4,
  refresh_interval_ms = 1 * 1000,
  dir = vim.fs.joinpath(vim.fn.stdpath("data"), "pomodoro"),
}

local M = {}

local state_file = vim.fs.joinpath(opts.dir, "state.json")

local state = {
  phase = phase.UNKNOWN,
  start = 0,
  now = 0,
  elapsed = 0,
  completed = 0,
  task_name = default_task_name,
}

local timer = nil

local function file_exists(file)
  return vim.uv.fs_stat(file) ~= nil
end

local function read_file(file)
  local fd = assert(io.open(file, "r"))
  ---@type string
  local data = fd:read("*a")
  fd:close()
  return data
end

local function write_file(file, contents)
  local fd = assert(io.open(file, "w+"))
  fd:write(contents)
  fd:close()
end

local osnotify = function(msg, title)
  local cmd = {
    "osascript",
    "-e",
    'display notification "' .. msg .. '" with title "' .. title .. '"',
  }
  vim.schedule(function()
    vim.system(cmd)
  end)
end

local notinfo = function(msg, title)
  if not title then
    title = "Pomodoro"
  end
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.INFO, { title = title })
  end)
  osnotify(msg, title)
end

local prompt_task_name = function(callback)
  vim.schedule(function()
    vim.ui.input(
      { prompt = "Task name (default: " .. default_task_name .. "): ", default = state.task_name },
      function(input)
        local task_name = (input and input ~= "") and input or default_task_name
        callback(task_name)
      end
    )
  end)
end

local save_state = function()
  local ok, json = pcall(function()
    return vim.fn.json_encode(state)
  end)
  if not ok then
    error("Error in json: " .. json)
  end

  write_file(state_file, json)
end

local load_state = function()
  if not file_exists(state_file) then
    write_file(state_file, "")
  end

  local content = read_file(state_file)

  local ok, new_state = pcall(function()
    return vim.fn.json_decode(content)
  end)
  if not ok then
    error("Error in new_state: " .. new_state)
  end

  if new_state and new_state ~= vim.NIL and new_state.phase ~= phase.UNKNOWN then
    new_state.elapsed = new_state.elapsed - (os.time() - new_state.now)
    state = new_state
  else
    state = {
      phase = phase.WORK,
      task_name = default_task_name,
      start = os.time(),
      now = os.time(),
      elapsed = 0,
      completed = 0,
    }
  end
end

local update_state = function()
  local delta = os.time() - state.now
  state.elapsed = state.elapsed + delta
  state.now = os.time()
  if state.phase == phase.WORK then
    if state.elapsed >= opts.work_interval then
      state.completed = state.completed + 1
      if state.completed >= opts.count then
        state.phase = phase.LONG_BREAK
        state.start = os.time()
        state.completed = 0
        state.elapsed = 0
        notinfo("Long break!")
      else
        state.phase = phase.BREAK
        state.start = os.time()
        state.elapsed = 0
        notinfo("Short break!")
      end
    end
  elseif state.phase == phase.BREAK then
    if state.elapsed >= opts.break_interval then
      state.phase = phase.WORK
      state.start = os.time()
      state.elapsed = 0
      notinfo("Focus!")
    end
  elseif state.phase == phase.LONG_BREAK then
    if state.elapsed >= opts.long_interval then
      state.phase = phase.WORK
      state.start = os.time()
      state.elapsed = 0
      notinfo("Focus!")
    end
  end
end

local function clearInterval()
  if not timer then
    return
  end
  timer:stop()
  timer:close()
  timer = nil
end

local function setInterval()
  local t = assert(vim.uv.new_timer())
  t:start(
    0,
    opts.refresh_interval_ms,
    vim.schedule_wrap(function()
      update_state()
      save_state()
    end)
  )
  timer = t
end

local open_stats = function()
  local res = require("plenary.window.float").centered({
    winblend = 0,
    percentage = 0.8,
  })
  api.nvim_buf_set_keymap(res.bufnr, "n", "q", ":q<CR>", { noremap = true, silent = true })

  local volt = require("volt")
  local ui = require("volt.ui")
  volt.gen_data({
    {
      buf = res.bufnr,
      xpad = 2,
      ns = vim.api.nvim_create_namespace("progress"),
      layout = {
        {
          name = "progress",
          lines = function()
            local progress = ui.progressbar({
              w = 10,
              val = 30,
              icon = { on = "█", off = "░" },
              hl = { on = "String", off = "Comment" },
            })
            -- Wrap the result properly
            return { progress }
          end,
        },
        {
          name = "progress",
          lines = function()
            local progress = ui.progressbar({
              w = 10,
              val = 30,
              icon = { on = "█", off = "░" },
              hl = { on = "String", off = "Comment" },
            })
            -- Wrap the result properly
            return { progress }
          end,
        },
      },
    },
  })
  volt.run(res.bufnr, { h = 10, w = 100 })
end

local handleAction = function(action)
  if action == actions.resume then
    load_state()
    clearInterval()
    setInterval()
    notinfo("Started, Focus!")
  elseif action == actions.stop then
    state.phase = phase.UNKNOWN
    state.start = os.time()
    save_state()
    clearInterval()
    notinfo("Stopped")
  elseif action == actions.short_break then
    state.phase = phase.BREAK
    state.start = os.time()
    state.elapsed = 0
    notinfo("Short break!")
  elseif action == actions.long_break then
    state.phase = phase.LONG_BREAK
    state.start = os.time()
    state.elapsed = 0
    notinfo("Long break!")
  elseif action == actions.work then
    state.phase = phase.WORK
    state.start = os.time()
    state.elapsed = 0
    notinfo("Focus!")
  elseif action == actions.change_task_name then
    if timer then
      prompt_task_name(function(task_name)
        state.task_name = task_name
        notinfo("Task name updated to: " .. task_name)
      end)
    end
  elseif action == actions.stats then
    open_stats()
  end
end

M.menu = function()
  local items = {}
  table.sort(actions)
  for _, v in pairs(actions) do
    if v == actions.change_task_name and not timer then
    else
      table.insert(items, { text = v, file = v })
    end
  end
  ---@type snacks.picker.Config
  local snacks_opts = {
    title = "Pomodoro actions",
    items = items,
    layout = {
      preset = "select",
    },
    confirm = function(picker, item)
      picker:close()
      handleAction(item.text)
    end,
  }
  Snacks.picker.pick(snacks_opts)
end

local progressbar = function(ops)
  ops = ops or {}

  local width = ops.width or 20
  local value = ops.value or 0
  local on_icon = ops.on_icon or "█"
  local off_icon = ops.off_icon or "░"

  -- Clamp value between 0 and 100
  value = math.max(0, math.min(100, value))

  local activelen = math.floor(width * (value / 100))
  local inactivelen = width - activelen

  return string.rep(on_icon, activelen) .. string.rep(off_icon, inactivelen)
end

M.status_color = function()
  if not state.phase or state.phase == phase.UNKNOWN then
    return ""
  end

  local color = ""

  if state.phase == phase.WORK then
    color = "@diff.delta"
  elseif state.phase == phase.BREAK then
    color = "WarningMsg"
  elseif state.phase == phase.LONG_BREAK then
    color = "@diff.minus"
  end

  return color
end

M.status = function()
  if not state.phase or state.phase == phase.UNKNOWN then
    return ""
  end

  local progress = ""
  if state.phase == phase.WORK then
    local perc = math.floor(state.elapsed / opts.work_interval * 100)
    progress = progressbar({ width = 20, value = perc })
  elseif state.phase == phase.BREAK then
    local perc = math.floor(state.elapsed / opts.break_interval * 100)
    progress = progressbar({ width = 20, value = perc })
  elseif state.phase == phase.LONG_BREAK then
    local perc = math.floor(state.elapsed / opts.long_interval * 100)
    progress = progressbar({ width = 20, value = perc })
  end

  local diff = state.elapsed
  local hours = math.floor(diff / 3600)
  local minutes = math.floor((diff % 3600) / 60)
  local seconds = diff % 60
  local elapsed = string.format("%d:%02d:%02d", hours, minutes, seconds)

  local count = string.format("%d/%d", state.completed, opts.count)

  return string.format("%s %s %s %s", state.phase, progress, elapsed, count)
end

return M
