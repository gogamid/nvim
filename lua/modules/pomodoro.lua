local M = {}
local volt = require("volt")
local voltstate = require("volt.state")
local voltui = require("volt.ui")
local opts = {
  daily_pomodoros_goal = 20,
  work_interval = 25 * 60,
  break_interval = 5 * 60,
  long_interval = 15 * 60,
  count = 4,
  refresh_interval_ms = 1 * 1000,
  dir = vim.fs.joinpath(vim.fn.stdpath("data"), "pomodoro"),
  default_task_name = "work",
  work_text = " ",
  break_text = " ",
  long_break_text = " ",
}

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
  UNKNOWN = 0,
  WORK = 1,
  BREAK = 2,
  LONG_BREAK = 3,
}
local phase_to_text = {
  [phase.UNKNOWN] = "",
  [phase.WORK] = opts.work_text,
  [phase.BREAK] = opts.break_text,
  [phase.LONG_BREAK] = opts.long_break_text,
}
local state_file = vim.fs.joinpath(opts.dir, "state.json")
local history_file = vim.fs.joinpath(opts.dir, "history.jsonl")

local state = {
  phase = phase.UNKNOWN,
  start_time = 0,
  mod_time = 0,
  elapsed_seconds = 0,
  completed = 0,
  task_name = opts.default_task_name,
}
local ui = {}
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

local function jq(filter)
  if vim.fn.executable("jq") == 0 then
    return nil, "jq not found"
  end
  if not file_exists(history_file) then
    return nil, "history file not found"
  end

  local cmd = "jq -sr " .. vim.fn.shellescape(filter) .. " " .. vim.fn.shellescape(history_file)
  local r = vim.system({ vim.o.shell, vim.o.shellcmdflag, cmd }):wait()
  if r.stderr ~= "" then
    return nil, r.stderr
  end

  local ok, result = pcall(function()
    return vim.fn.json_decode(r.stdout)
  end)
  if not ok then
    return nil, result
  end

  return result, nil
end

local prompt_task_name = function()
  local task_names, err = jq("[.[] | .task_name] | unique | sort | map({text: .})")
  if err then
    vim.notify(err, vim.log.levels.ERROR)
  end
  if not task_names then
    task_names = {}
  end
  Snacks.picker({
    finder = function(_, ctx)
      return vim.list_extend({ { text = ctx.filter.search } }, task_names)
    end,
    format = "text",
    live = true,
    confirm = function(p, it, _)
      state.task_name = it.text
      p:close()
    end,
    title = "New Task Name",
    layout = {
      preset = "select",
      layout = {
        max_width = 30,
        max_height = 10,
      },
    },
  })
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

local append_to_history = function()
  local ok, json = pcall(function()
    return vim.fn.json_encode(state)
  end)
  if not ok then
    error("Error encoding session: " .. json)
  end

  local fd = assert(io.open(history_file, "a"))
  fd:write(json .. "\n")
  fd:close()
end

local load_state = function()
  if not file_exists(state_file) then
    write_file(state_file, "")
  end

  local content = read_file(state_file)
  if content == "" then
    content = "{}"
  end

  local ok, new_state = pcall(function()
    return vim.fn.json_decode(content)
  end)
  if not ok then
    error("Error in new_state: " .. new_state)
  end

  if new_state and new_state ~= vim.NIL and new_state.phase ~= phase.UNKNOWN then
    notinfo("State found, updating")
    state = vim.tbl_deep_extend("force", state, new_state)
    state.elapsed_seconds = state.elapsed_seconds - (os.time() - state.mod_time)
  else
    notinfo("State not found, creating new")
    state.phase = phase.WORK
    state.task_name = opts.default_task_name
    state.start_time = os.time()
    state.mod_time = os.time()
    state.completed = 0
    state.elapsed_seconds = 0
  end
end

local update_state = function()
  local delta = os.time() - state.mod_time
  state.elapsed_seconds = state.elapsed_seconds + delta
  state.mod_time = os.time()
  if state.phase == phase.WORK then
    if state.elapsed_seconds >= opts.work_interval then
      append_to_history()
      state.completed = state.completed + 1
      if state.completed >= opts.count then
        state.phase = phase.LONG_BREAK
        state.start_time = os.time()
        state.completed = 0
        state.elapsed_seconds = 0
        notinfo("Long break!")
      else
        state.phase = phase.BREAK
        state.start_time = os.time()
        state.elapsed_seconds = 0
        notinfo("Short break!")
      end
    end
  elseif state.phase == phase.BREAK then
    if state.elapsed_seconds >= opts.break_interval then
      append_to_history()
      state.phase = phase.WORK
      state.start_time = os.time()
      state.elapsed_seconds = 0
      notinfo("Focus!")
    end
  elseif state.phase == phase.LONG_BREAK then
    if state.elapsed_seconds >= opts.long_interval then
      append_to_history()
      state.phase = phase.WORK
      state.start_time = os.time()
      state.elapsed_seconds = 0
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

local function ts_to_str(ts)
  return os.date("%Y-%m-%d %H:%M", ts)
end

local function ts_to_time_str(ts)
  return os.date("%H:%M", ts)
end

local function ts_to_date_str(ts)
  return os.date("%Y-%m-%d", ts)
end

local function s_to_mm_ss(s)
  local m = math.floor(s / 60)
  local ss = math.floor(s % 60)
  return string.format("%02d:%02d", m, ss)
end

local progress = function()
  local w_with_pad = ui.w - (2 * ui.xpad)
  local w = w_with_pad / 3 - 1
  local today = math.floor(os.time() / 86400)
  local today_filter = string.format(
    ". | map(select((.mod_time / 86400 | floor) == (%d) and .phase == 1)) | sort_by(.mod_time) | reverse | map(.elapsed_seconds) | add | { total_seconds: ., hours: (. / 3600 | floor), minutes: ((. %% 3600) / 60 | floor)}",
    today
  )
  local data, _ = jq(today_filter)
  if not data then
    return
  end
  local goal_seconds = opts.daily_pomodoros_goal * opts.work_interval

  local today_hours = string.format("%dh%dm", data.hours, data.minutes)
  local goal_hours = math.floor(goal_seconds / 3600) .. "h"

  local today_focus_time_component = {
    { { " ", "DiagnosticSignOk" }, { " Today " }, { today_hours .. "/" .. goal_hours } },
  }

  local today_poms_filter =
    string.format(". | map(select((.mod_time / 86400 | floor) == (%d) and .phase == 1)) | length", today)
  local poms_count, _ = jq(today_poms_filter)
  if not poms_count then
    return
  end
  local today_pomodoros_component = {
    {
      { " ", "DiagnosticSignError" },
      { " Pomodoros " },
      { poms_count .. "/" .. tostring(opts.daily_pomodoros_goal) },
    },
  }

  local streak_days_filter = [[
 map(select(.phase == 1) | .mod_time / 86400 | floor) |
  unique |
  sort | reverse |
  reduce .[] as $day (
    {streak: 0, expected: null};
    if .expected == null or $day == (.expected - 1) then
      .streak += 1 | .expected = $day
    else
      .
    end
  ) | .streak
  ]]
  local streak_days, _ = jq(streak_days_filter)
  if not streak_days then
    streak_days = 0
  end

  local streak = string.format("%dd", streak_days)
  local streak_days_component = {
    { { " ", "DiagnosticSignWarn" }, { " Streak " }, { streak } },
  }

  return voltui.grid_col({
    { lines = today_focus_time_component, w = w, pad = 2 },
    { lines = today_pomodoros_component, w = w, pad = 2 },
    { lines = streak_days_component, w = w },
  })
end
local dashboard = function()
  return voltui.grid_row({
    progress(),
    { {} },
    -- {
    --   lines = { { voltui.progressbar({ val = today_perc, w = w_col }) } },
    -- },
  })
end

local gen_history_component = function()
  local hs, _ = jq(". | sort_by(.mod_time) | reverse")
  if not hs then
    hs = {}
  end
  local tbl = {
    { "Type", "Task", "Date", "Start", "End", "Duration" },
  }
  for _, h in ipairs(hs) do
    local start_time = ts_to_time_str(h.start_time)
    local end_time = ts_to_time_str(h.mod_time)
    local date = ts_to_date_str(h.start_time)
    local duration = s_to_mm_ss(h.elapsed_seconds)
    local type = phase_to_text[h.phase]
    table.insert(tbl, { type, h.task_name, date, start_time, end_time, duration })
  end
  return voltui.table(tbl, 80)
end

local gen_layout = function()
  local today = "Today"
  local history = "History"
  local tabs = { today, history }
  local active = today
  return {
    -- {
    --   lines = function()
    --     return voltui.tabs(tabs, ui.w, { active = active })
    --   end,
    --   name = "tabs",
    -- },
    {
      lines = function()
        if active == history then
          return gen_history_component()
        elseif active == today then
          return dashboard()
        else
          return { {} }
        end
      end,
      name = "stats",
    },
  }
end

local open_stats = function()
  local float = Snacks.win({ width = 0.8, height = 0.6, border = "rounded" })
  ui.buf = float.buf
  ui.win = float.win

  api.nvim_buf_set_keymap(ui.buf, "n", "q", ":q<CR>", {})
  api.nvim_buf_set_keymap(ui.buf, "n", "j", "<C-f>", {})
  api.nvim_buf_set_keymap(ui.buf, "n", "k", "<C-b>", {})

  ui.w = 80
  ui.ns = api.nvim_create_namespace("pomodoro")
  ui.xpad = 2
  volt.gen_data({ { layout = gen_layout(), buf = ui.buf, xpad = ui.xpad, ns = ui.ns } })
  ui.h = voltstate[ui.buf].h

  api.nvim_win_set_hl_ns(ui.win, ui.ns)

  volt.run(ui.buf, { h = ui.h + 1, w = ui.w - (2 * ui.xpad) })
end

local handleAction = function(action)
  if action == actions.resume then
    load_state()
    clearInterval()
    setInterval()
    notinfo("Started, Focus!")
  elseif action == actions.stop then
    state.phase = phase.UNKNOWN
    state.start_time = os.time()
    save_state()
    clearInterval()
    notinfo("Stopped")
  elseif action == actions.short_break then
    state.phase = phase.BREAK
    state.start_time = os.time()
    state.elapsed_seconds = 0
    notinfo("Short break!")
  elseif action == actions.long_break then
    state.phase = phase.LONG_BREAK
    state.start_time = os.time()
    state.elapsed_seconds = 0
    notinfo("Long break!")
  elseif action == actions.work then
    state.phase = phase.WORK
    state.start_time = os.time()
    state.elapsed_seconds = 0
    notinfo("Focus!")
  elseif action == actions.change_task_name then
    if timer then
      prompt_task_name()
    end
  elseif action == actions.stats then
    open_stats()
  end
end

M.menu = function()
  local items = {}
  if not timer then
    table.insert(items, actions.resume)
  end
  if timer then
    table.insert(items, actions.change_task_name)
    if state.phase == phase.WORK then
      table.insert(items, actions.long_break)
      table.insert(items, actions.short_break)
    end
    if state.phase == phase.LONG_BREAK then
      table.insert(items, actions.work)
    end
    if state.phase == phase.BREAK then
      table.insert(items, actions.work)
    end
    table.insert(items, actions.stop)
  end
  table.insert(items, actions.stats)

  Snacks.picker.select(items, {
    prompt = "Pomodoro",
    snacks = {
      layout = {
        layout = {
          max_width = 30,
        },
      },
    },
  }, function(item, _)
    handleAction(item)
  end)
end

local progressbar = function(ops)
  ops = ops or {}

  local width = ops.width or 20
  local value = ops.value or 0

  local on_icon_left = ""
  local on_icon_mid = ""
  local on_icon_right = ""

  local off_icon_left = ""
  local off_icon_mid = ""
  local off_icon_right = ""

  value = math.max(0, math.min(100, value))

  local activelen = math.floor(width * (value / 100))
  local inactivelen = width - activelen

  local active_part = ""
  if activelen > 0 then
    if inactivelen == 0 and activelen >= 2 then
      active_part = on_icon_left .. string.rep(on_icon_mid, activelen - 2) .. on_icon_right
    else
      active_part = on_icon_left .. string.rep(on_icon_mid, activelen - 1)
    end
  end

  local inactive_part = ""
  if inactivelen > 0 then
    if activelen == 0 then
      inactive_part = off_icon_left .. string.rep(off_icon_mid, inactivelen - 2) .. off_icon_right
    else
      inactive_part = string.rep(off_icon_mid, inactivelen - 1) .. off_icon_right
    end
  end

  return active_part .. inactive_part
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
    local perc = math.floor(state.elapsed_seconds / opts.work_interval * 100)
    progress = progressbar({ width = 10, value = perc })
  elseif state.phase == phase.BREAK then
    local perc = math.floor(state.elapsed_seconds / opts.break_interval * 100)
    progress = progressbar({ width = 10, value = perc })
  elseif state.phase == phase.LONG_BREAK then
    local perc = math.floor(state.elapsed_seconds / opts.long_interval * 100)
    progress = progressbar({ width = 10, value = perc })
  end

  local diff = state.elapsed_seconds
  local minutes = math.floor((diff % 3600) / 60)
  local seconds = diff % 60
  local elapsed = string.format("%02d:%02d", minutes, seconds)

  local count = string.format("%d/%d", state.completed, opts.count)

  return string.format("%s %s %s %s %s", phase_to_text[state.phase], state.task_name, progress, elapsed, count)
end

return M
