local M = {}

local info = function(msg, title)
  vim.schedule(function()
    vim.notify(vim.inspect(msg), vim.log.levels.INFO, { title = title })
  end)
end

local err = function(msg, title)
  vim.schedule(function()
    vim.notify(vim.inspect(msg), vim.log.levels.ERROR, { title = title })
  end)
end

local opts = {
  work_interval = 25,
  break_interval = 5,
  long_interval = 15,
  count = 4,
  refresh_interval_ms = 5 * 1000,
}

local state = {
  phase = nil, -- work | break | long_break
  start = nil,
  now = nil,
  completed = 0,
  timer = nil,
}

local update_state = function()
  state.now = os.time()
  local diff = state.now - state.start
  if state.phase == "work" then
    if diff >= opts.work_interval then
      state.completed = state.completed + 1
      state.phase = "break"
      state.start = os.time()
    end
  elseif state.phase == "break" then
    if diff >= opts.break_interval then
      state.phase = "work"
      state.start = os.time()
    end
  end
end

local function clearInterval()
  if not state.timer then
    return
  end
  state.timer:stop()
  state.timer:close()
  state.timer = nil
end

local function setInterval()
  clearInterval()
  local timer = vim.uv.new_timer()
  timer:start(0, opts.refresh_interval_ms, vim.schedule_wrap(update_state))
  state.timer = timer
end

local handleAction = function(action)
  if action == "start" then
    state.phase = "work"
    state.start = os.time()
    setInterval()
  elseif action == "stop" then
    state.phase = nil
    state.start = os.time()
    clearInterval()
  end
end

M.menu = function()
  ---@type snacks.picker.finder.Item[]
  local items = {
    { text = "start", file = "start" },
    { text = "stop", file = "stop" },
  }
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
M.status = function()
  if not state.phase then
    return ""
  end

  return string.format("%s, %d/%d", state.phase, state.completed, opts.count)
end
return M
