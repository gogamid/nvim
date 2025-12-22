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
  completed = 0,
}

local update_state = function()
  if state.phase == nil then
    state.phase = "work"
    state.start = os.time()
  end
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

local start = function()
  local timer = vim.loop.new_timer()

  local function on_tick()
    update_state()
  end

  timer:start(0, opts.refresh_interval_ms, vim.schedule_wrap(on_tick))
end

local handleAction = function(action)
  if action == "start" then
    start()
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
return M
