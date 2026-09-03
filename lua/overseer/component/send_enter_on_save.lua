local files = require("overseer.files")
local log = require("overseer.log")

---@type overseer.ComponentFileDefinition
return {
  desc = "Send Enter to the running task on :write and notify on rebuild success/failure",

  params = {
    paths = {
      desc = "Only send Enter when writing files in these paths (can be directory or file)",
      type = "list",
      optional = true,
      subtype = {
        validate = function(v)
          return files.exists(v)
        end,
      },
    },
    delay = {
      desc = "How long to wait (in ms) before sending Enter",
      type = "number",
      default = 300,
      validate = function(v)
        return v > 0
      end,
    },
    mode = {
      desc = "How to watch the paths",
      type = "enum",
      choices = { "autocmd", "uv" },
      default = "autocmd",
      long_desc = "'autocmd' will set autocmds on BufWritePost. 'uv' will use a libuv file watcher (recursive watching may not be supported on all platforms).",
    },
    notify = {
      desc = "Notify via vim.notify when a rebuild cycle completes after sending Enter",
      type = "boolean",
      default = true,
    },
    success_delay = {
      desc = "Delay (ms) before showing the success notification (0 = show immediately)",
      type = "number",
      default = 5000,
      validate = function(v)
        return v >= 0
      end,
    },
    done_pattern = {
      desc = "Lua pattern that marks the end of a rebuild cycle",
      type = "string",
      default = "Press any key to rebuild/redeploy",
    },
    error_patterns = {
      desc = "Lua patterns that indicate the rebuild failed",
      type = "list",
      optional = true,
    },
  },

  constructor = function(opts)
    vim.validate("delay", opts.delay, "number")
    vim.validate("done_pattern", opts.done_pattern, "string")
    vim.validate("success_delay", opts.success_delay, "number")

    -- Defaults tuned to `skaffold dev --trigger=manual` output (see sit.lua):
    -- every cycle ends with "Press any key to rebuild/redeploy the changes", and
    -- a cycle is classified as a failure if any error pattern appears, otherwise
    -- it is treated as a successful rebuild.
    local error_patterns = opts.error_patterns or {
      "^make%[%d+%]: %*%*%*",
      "Error %d+",
      "build error",
      "building custom artifact",
      "Skipping test and deploy due to build error",
      "cannot use ",
      ".go:%d+:%d+",
    }
    local done_pattern = opts.done_pattern

    local function matches_any(line, patterns)
      for _, p in ipairs(patterns) do
        if line:find(p) then
          return true
        end
      end
      return false
    end

    local function is_watching_file(path)
      if not opts.paths or vim.tbl_isempty(opts.paths) then
        return true
      end
      for _, watch_path in ipairs(opts.paths) do
        if files.is_subpath(watch_path, path) then
          return true
        end
      end
      return false
    end

    -- Rebuild-cycle state (armed the first time we send Enter)
    local in_cycle = false
    local cycle_error = false
    local success_timer = nil

    local function arm_cycle()
      in_cycle = true
      cycle_error = false
    end

    local function cancel_success_timer()
      if success_timer then
        vim.fn.timer_stop(success_timer)
        success_timer = nil
      end
    end

    local function finish_cycle(task)
      local failed = cycle_error
      in_cycle = false
      local msg = string.format(
        "%s %s",
        task.name,
        failed and "build failed" or "rebuilt successfully"
      )
      local level = failed and vim.log.levels.ERROR or vim.log.levels.INFO
      if failed or opts.success_delay == 0 then
        vim.notify(msg, level)
      else
        -- The new image still needs a moment to be deployed & picked up by the
        -- UI, so delay the success notification a bit.
        cancel_success_timer()
        success_timer = vim.defer_fn(function()
          success_timer = nil
          vim.notify(msg, level)
        end, opts.success_delay)
      end
    end

    local function send_enter(task)
      -- Only send to a live process
      if not task:is_running() or task:is_disposed() then
        return
      end
      local strategy = task.strategy
      if strategy == nil or strategy.job_id == nil or strategy.job_id <= 0 then
        return
      end
      -- "\r" is what a terminal sends when you press Enter in the task buffer
      local ok, err = pcall(vim.api.nvim_chan_send, strategy.job_id, "\r")
      if not ok then
        log.warn("Overseer[send_enter_on_save] failed to send Enter: %s", err)
        return
      end
      -- Arm the completion watcher for this rebuild cycle (don't reset if one is
      -- already being watched, so an extra save doesn't lose the running cycle)
      if opts.notify and not in_cycle then
        arm_cycle()
      end
    end

    local pending = false
    local version = 1
    local function trigger_enter(task)
      local trigger_version = version
      if not pending then
        pending = true
        vim.defer_fn(function()
          pending = false
          if version == trigger_version and not task:is_disposed() then
            send_enter(task)
          end
        end, opts.delay)
      end
    end

    return {
      autocmd_id = nil,
      fs_events = {},
      on_init = function(self, task)
        if opts.mode == "uv" then
          for _, path in ipairs(opts.paths or {}) do
            local fs_event = assert(vim.uv.new_fs_event())
            fs_event:start(
              path,
              { recursive = true },
              vim.schedule_wrap(function(err, _, _)
                if err then
                  log.warn("Overseer[send_enter_on_save] watch error: %s", err)
                else
                  trigger_enter(task)
                end
              end)
            )
            table.insert(self.fs_events, fs_event)
          end
        else
          self.autocmd_id = vim.api.nvim_create_autocmd("BufWritePost", {
            pattern = "*",
            desc = string.format("Send Enter to task %s on save", task.name),
            callback = function(params)
              -- Only care about regular files
              if vim.bo[params.buf].buftype == "" then
                local bufname = vim.api.nvim_buf_get_name(params.buf)
                if is_watching_file(bufname) then
                  trigger_enter(task)
                end
              end
            end,
          })
        end
      end,
      on_output_lines = function(self, task, lines)
        if not in_cycle then
          return
        end
        for _, raw in ipairs(lines) do
          local line = raw:gsub("[\r\n]+$", ""):gsub("^%s+", ""):gsub("%s+$", "")
          if line == "" then
            -- skip
          elseif line:find(done_pattern) then
            finish_cycle(task)
            return
          elseif not cycle_error and matches_any(line, error_patterns) then
            cycle_error = true
          end
        end
      end,
      on_reset = function(self, task)
        -- Invalidate any pending sends and cycle watching
        version = version + 1
        pending = false
        in_cycle = false
        cycle_error = false
        cancel_success_timer()
      end,
      on_complete = function(self, task)
        in_cycle = false
        cycle_error = false
        cancel_success_timer()
      end,
      on_dispose = function(self, task)
        version = version + 1
        in_cycle = false
        cancel_success_timer()
        if self.autocmd_id then
          vim.api.nvim_del_autocmd(self.autocmd_id)
          self.autocmd_id = nil
        end
        for _, fs_event in ipairs(self.fs_events) do
          fs_event:stop()
        end
        self.fs_events = {}
      end,
    }
  end,
}
