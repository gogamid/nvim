-- `:restart` starts a new Nvim server and kills every overseer task job, so snapshot the running
-- tasks and re-start them in the restarted server.
--
-- The snapshot is also refreshed on every task list update, because `:restart` spawns the new
-- server before the old one runs its VimLeavePre autocmds.
local M = {}

local pid = vim.fn.getpid()
-- pid of the process that restarted us, handed over through the environment
local prev_pid = tonumber(vim.env.OVERSEER_RESTORE_PID)
vim.env.OVERSEER_RESTORE_PID = tostring(pid)

-- only tasks that were still running are worth re-starting
local RESTORABLE = { RUNNING = true }
-- these buffers cannot be saved in a session, their windows come back as empty splits
local OVERSEER_FT = { OverseerList = true, OverseerOutput = true }
-- set by prepare_restart, which closes the overseer windows before the session is saved
local prepared_layout = nil

---@param for_pid integer
---@return string
local function state_file(for_pid)
  return ("%s/overseer_restore_%d.json"):format(vim.fn.stdpath("state"), for_pid)
end

---@param other_pid integer
---@return boolean
local function is_running(other_pid)
  local _, err = vim.uv.kill(other_pid, 0)
  return err == nil or not tostring(err):find("ESRCH")
end

---@param other_pid? integer
local function delete_snapshot_if_dead(other_pid)
  if not other_pid or other_pid == pid or is_running(other_pid) then
    return
  end
  vim.fn.delete(state_file(other_pid))
end

---@return integer[]
local function overseer_wins()
  local wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if OVERSEER_FT[vim.bo[vim.api.nvim_win_get_buf(win)].filetype] then
      table.insert(wins, win)
    end
  end
  return wins
end

---@return { count: integer, task_list_open: boolean }
local function current_layout()
  local count, task_list_open = 0, false
  for _, win in ipairs(overseer_wins()) do
    count = count + 1
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "OverseerList" then
      task_list_open = true
    end
  end
  return { count = count, task_list_open = task_list_open }
end

---@return boolean
local function is_list_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "OverseerList" then
      return true
    end
  end
  return false
end

local function open_list()
  local ok, overseer = pcall(require, "overseer")
  if ok and not is_list_open() then
    overseer.open({ enter = false })
  end
end

---@param def table
---@return table|nil
local function encodable(def)
  -- new_task rebuilds the task from its template when from_template is set, the snapshot must stand alone
  def.from_template = nil
  if pcall(vim.json.encode, def) then
    return def
  end
  return nil
end

---@return table[]|nil
local function snapshot()
  local ok, overseer = pcall(require, "overseer")
  if not ok then
    return nil
  end
  local defs = {}
  for _, task in ipairs(overseer.list_tasks()) do
    if RESTORABLE[task.status] and not task.ephemeral then
      local def = encodable(task:serialize())
      if def then
        table.insert(defs, def)
      else
        vim.notify_once("overseer_restore: cannot persist " .. task.name, vim.log.levels.WARN)
      end
    end
  end
  return defs
end

---@param force? boolean Write even while nvim is exiting
local function write(force)
  -- killing the task jobs on exit flips their status, that must not overwrite the snapshot
  if not force and vim.v.exitreason ~= "" then
    return
  end
  local defs = snapshot()
  if not defs then
    return
  end
  local layout = current_layout()
  local task_list_open, window_count = layout.task_list_open, layout.count
  if prepared_layout then
    -- prepare_restart already closed the overseer windows, so no saved session contains them
    task_list_open = prepared_layout.task_list_open
    window_count = 0
  end
  local payload = { tasks = defs, task_list_open = task_list_open, window_count = window_count }
  local tmp = state_file(pid) .. ".tmp"
  local fd = io.open(tmp, "w")
  if not fd then
    vim.notify("overseer_restore: cannot write " .. tmp, vim.log.levels.ERROR)
    return
  end
  fd:write(vim.json.encode(payload))
  fd:close()
  vim.uv.fs_rename(tmp, state_file(pid))
end

---Snapshot the running tasks, then close the task list and task output windows, because the
---session saved by `:restart` would otherwise restore empty splits in their place
function M.prepare_restart()
  prepared_layout = { task_list_open = current_layout().task_list_open }
  write(false)
  for _, win in ipairs(overseer_wins()) do
    pcall(vim.api.nvim_win_close, win, true)
  end
  -- we are still alive if nvim refused to exit (e.g. E37 for a modified buffer), put the windows back
  vim.defer_fn(function()
    if not prepared_layout then
      return
    end
    local list_open = prepared_layout.task_list_open
    prepared_layout = nil
    if list_open then
      open_list()
    end
  end, 500)
end

---@param from_pid integer
---@return table|nil
local function take_payload(from_pid)
  local path = state_file(from_pid)
  local fd = io.open(path, "r")
  if not fd then
    return nil
  end
  local content = fd:read("*a")
  fd:close()
  vim.fn.delete(path)
  local ok, payload = pcall(vim.json.decode, content)
  if not ok or type(payload) ~= "table" then
    vim.notify("overseer_restore: cannot read " .. path, vim.log.levels.WARN)
    return nil
  end
  if payload.tasks == nil and payload[1] ~= nil then
    payload = { tasks = payload }
  end
  return payload
end

---@param win integer
---@param buf integer
---@return boolean
local function is_session_split(win, buf)
  return vim.api.nvim_win_get_config(win).relative == ""
    and vim.bo[buf].buftype == ""
    and vim.bo[buf].filetype == ""
    and not vim.bo[buf].modified
    and vim.api.nvim_buf_get_name(buf) == ""
    and vim.api.nvim_buf_line_count(buf) <= 1
end

---Sessions cannot save these buffers, so restoring one recreates their windows as empty splits
---@param count integer number of overseer windows the snapshot was taken with
---@return integer closed
local function close_unrestorable_splits(count)
  local closed = 0
  while closed < count do
    local target = nil
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
      local wins = vim.api.nvim_tabpage_list_wins(tab)
      if #wins > 1 then
        for _, win in ipairs(wins) do
          if is_session_split(win, vim.api.nvim_win_get_buf(win)) then
            target = win
            break
          end
        end
      end
      if target then
        break
      end
    end
    if not target or not pcall(vim.api.nvim_win_close, target, true) then
      return closed
    end
    closed = closed + 1
  end
  return closed
end

---Re-start the tasks that were running in the previous server
function M.restore()
  local reason = vim.v.startreason
  if reason ~= "restart" and reason ~= "restart!" then
    return
  end
  if not prev_pid then
    return
  end
  local payload = take_payload(prev_pid)
  -- the previous process may write its snapshot again while it is exiting
  vim.defer_fn(function()
    delete_snapshot_if_dead(prev_pid)
  end, 15000)
  if not payload then
    return
  end
  local window_count = tonumber(payload.window_count) or 0
  local task_list_open = payload.task_list_open == true
  local defs = type(payload.tasks) == "table" and payload.tasks or {}
  local closed = close_unrestorable_splits(window_count)
  local ok, overseer = pcall(require, "overseer")
  if not ok then
    return
  end
  local restored, failed = 0, 0
  for _, def in ipairs(defs) do
    local created, task = pcall(overseer.new_task, def)
    if not created then
      failed = failed + 1
      vim.notify("overseer_restore: cannot restore " .. tostring(def.name), vim.log.levels.ERROR)
    else
      local started = pcall(task.start, task)
      if started then
        restored = restored + 1
      else
        failed = failed + 1
        vim.notify("overseer_restore: cannot start " .. tostring(def.name), vim.log.levels.ERROR)
      end
    end
  end
  if task_list_open then
    open_list()
  end
  -- the layout of some restart flows is only restored after VimEnter
  vim.defer_fn(function()
    close_unrestorable_splits(window_count - closed)
    if task_list_open then
      open_list()
    end
  end, 1000)
  if restored > 0 or failed > 0 then
    local suffix = failed > 0 and (", " .. failed .. " failed") or ""
    vim.notify(("overseer_restore: restored %d task(s)%s"):format(restored, suffix))
  end
end

---Delete snapshots of nvim processes that are gone, keep the one we inherited
local function cleanup_stale_files()
  local pattern = ("%s/overseer_restore_*.json*"):format(vim.fn.stdpath("state"))
  for _, path in ipairs(vim.fn.glob(pattern, false, true)) do
    local other = tonumber(vim.fs.basename(path):match("^overseer_restore_(%d+)"))
    if other and other ~= pid and other ~= prev_pid and not is_running(other) then
      vim.fn.delete(path)
    end
  end
end

function M.setup()
  cleanup_stale_files()
  local group = vim.api.nvim_create_augroup("OverseerTaskRestore", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "OverseerListUpdate",
    desc = "Snapshot running overseer tasks",
    callback = function()
      write(false)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave" }, {
    group = group,
    desc = "Snapshot when the task list or task output windows change",
    callback = function(args)
      if OVERSEER_FT[vim.bo[args.buf].filetype] then
        write(false)
      end
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    desc = "Snapshot running overseer tasks before exiting",
    callback = function()
      local reason = vim.v.exitreason
      if reason == "restart" or reason == "restart!" then
        write(true)
      end
    end,
  })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    desc = "Restore overseer tasks after a restart",
    callback = function()
      vim.schedule(M.restore)
    end,
  })
end

return M
