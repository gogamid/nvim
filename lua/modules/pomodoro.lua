local M = {}

local info = function(msg, title)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.INFO, { title = title })
  end)
end

local err = function(msg, title)
  vim.schedule(function()
    vim.notify(vim.inspect(msg), vim.log.levels.ERROR, { title = title })
  end)
end

local phase = {
  UNKNOWN = "",
  WORK = "work",
  BREAK = "break",
  LONG_BREAK = "long break",
}

local opts = {
  work_interval = 15,
  break_interval = 5,
  long_interval = 10,
  count = 4,
  refresh_interval_ms = 1 * 1000,
}

local state = {
  phase = phase.UNKNOWN,
  start = nil,
  now = nil,
  completed = 0,
  timer = nil,
}

local update_state = function()
  state.now = os.time()
  local diff = state.now - state.start
  if state.phase == phase.WORK then
    if diff >= opts.work_interval then
      state.completed = state.completed + 1
      if state.completed >= opts.count then
        state.completed = 0
        state.phase = phase.LONG_BREAK
        state.start = os.time()
        info("Long break!")
      else
        state.phase = phase.BREAK
        state.start = os.time()
        info("Short break!")
      end
    end
  elseif state.phase == phase.BREAK then
    if diff >= opts.break_interval then
      state.phase = phase.WORK
      state.start = os.time()
      info("Focus!")
    end
  elseif state.phase == phase.LONG_BREAK then
    if diff >= opts.long_interval then
      state.phase = phase.WORK
      state.start = os.time()
      info("Focus!")
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
    state.phase = phase.WORK
    state.start = os.time()
    setInterval()
    info("pomodoro started")
  elseif action == "stop" then
    state.phase = phase.UNKNOWN
    state.start = os.time()
    clearInterval()
    info("pomodoro stopped")
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
  if not state.phase or state.phase == phase.UNKNOWN then
    return ""
  end

  local diff = state.now - state.start
  local duration = string.format("%d:%d:%d", diff / 360, diff / 60, diff)
  return string.format("%s %s %d/%d", state.phase, duration, state.completed, opts.count)
end

return M
