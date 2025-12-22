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
  completed = 0,
}

local timer = nil

local save_state = function(st)
  local path = vim.fn.expand(state_file)
  local json = vim.fn.json_encode(st)

  local ok, err = pcall(function()
    vim.fn.writefile({ json }, path)
  end)

  if not ok then
    vim.notify("Failed to save: " .. err, vim.log.levels.ERROR)
  end
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
  if new_state.phase ~= "" then
    state = new_state
  else
    state = {
      phase = phase.WORK,
      start = os.time(),
      now = os.time(),
      completed = 0,
    }
  end
end

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
        notinfo("Long break!")
      else
        state.phase = phase.BREAK
        state.start = os.time()
        notinfo("Short break!")
      end
    end
  elseif state.phase == phase.BREAK then
    if diff >= opts.break_interval then
      state.phase = phase.WORK
      state.start = os.time()
      notinfo("Focus!")
    end
  elseif state.phase == phase.LONG_BREAK then
    if diff >= opts.long_interval then
      state.phase = phase.WORK
      state.start = os.time()
      notinfo("Focus!")
    end
  end
  notinfo(vim.inspect(state))
  save_state(state)
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
  clearInterval()
  local t = vim.uv.new_timer()
  t:start(0, opts.refresh_interval_ms, vim.schedule_wrap(update_state))
  timer = t
end

local handleAction = function(action)
  if action == "start" then
    load_state()
    setInterval()
    notinfo("pomodoro started")
  elseif action == "stop" then
    state.phase = phase.UNKNOWN
    state.start = os.time()
    save_state()
    clearInterval()
    notinfo("pomodoro stopped")
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
