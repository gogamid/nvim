local M = {}

local notinfo = function(msg, title)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.INFO, { title = title })
  end)
end

local noterr = function(msg, title)
  vim.schedule(function()
    vim.notify(vim.inspect(msg), vim.log.levels.ERROR, { title = title })
  end)
end

local actions = {
  resume = "Resume Pomodoro",
  stop = "Stop Pomodoro",
  short_break = "Short Break",
  long_break = "Long break",
  work = "Work",
}
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
  dir = vim.fs.joinpath(vim.fn.stdpath("data"), "pomodoro"),
}

local state_file = vim.fs.joinpath(opts.dir, "state.json")

local state = {
  phase = phase.UNKNOWN,
  start = 0,
  now = 0,
  elapsed = 0,
  completed = 0,
}

local timer = nil

local save_state = function()
  local path = vim.fn.expand(state_file)
  local json = vim.fn.json_encode(state)
  local f = io.open(path, "w+")
  if not f then
    noterr("failed to write")
    return
  end
  f:write(json)
  f:close()
end

local load_state = function()
  local f = io.open(state_file, "r")
  if not f then
    noterr("failed to read")
  end
  local content = f:read("*all")
  f:close()
  local new_state
  local ok, err = pcall(function()
    new_state = vim.fn.json_decode(content)
  end)
  if not ok then
    noterr(err)
  end
  if new_state and new_state ~= vim.NIL and new_state.phase ~= phase.UNKNOWN then
    print("DEBUGPRINT[648]: pomodoro.lua:76: new_state.phase =" .. vim.inspect(new_state.phase))
    new_state.elapsed = new_state.elapsed - (os.time() - new_state.now)
    state = new_state
  else
    state = {
      phase = phase.WORK,
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
  save_state()
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
  local t = vim.uv.new_timer()
  t:start(0, opts.refresh_interval_ms, vim.schedule_wrap(update_state))
  timer = t
end

local handleAction = function(action)
  if action == actions.resume then
    load_state()
    clearInterval()
    setInterval()
    notinfo("pomodoro started")
  elseif action == actions.stop then
    state.phase = phase.UNKNOWN
    state.start = os.time()
    save_state()
    clearInterval()
    notinfo("pomodoro stopped")
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
  end
end

M.menu = function()
  local items = {}
  for _, v in pairs(actions) do
    table.insert(items, { text = v, file = v })
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

M.status = function()
  if not state.phase or state.phase == phase.UNKNOWN then
    return ""
  end

  local diff = state.elapsed
  local duration = string.format("%d:%d:%d", diff / 360, diff / 60, diff)
  return string.format("%s %s %d/%d", state.phase, duration, state.completed, opts.count)
end

return M
