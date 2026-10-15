--- Keeps `go test` runs off Neovim's main loop.
---
--- Two neotest-golang hot spots are patched here:
---
--- 1. `lib/cmd.lua` shells out to `go list -json` with `vim.system(...):wait()`.
---    That is a hard main-loop block, and `runspec/{test,file,dir}.lua` call it on
---    every single run with no caching, so pressing a test key freezes the editor
---    for as long as `go list` takes. Memoized per directory here.
---
--- 2. `lib/stream.lua` hands neotest a per-chunk iterator, and neotest pushes
---    every yielded table through `results_callback`, which walks the whole test
---    tree and redraws every consumer. With `-v` + `--format=standard-verbose`
---    that is thousands of redraws per run and the event loop never gets a
---    chance to breathe. The stream is rate-limited here instead.

local M = {}

--- @type integer Minimum milliseconds between emitted stream updates.
local STREAM_INTERVAL_MS = 100

--- @type table<string, { key: string, data: table, err: string|nil }>
local golist_cache = {}

--- Cheap identity of a directory's go package: the directory's own mtime (changes
--- when a test file is added/removed) plus the mtime of the nearest go.mod
--- (changes when modules or dependencies change). Anything that alters the
--- `go list` output we care about (Dir, ImportPath, TestGoFiles, XTestGoFiles)
--- moves one of those two.
---@param cwd string
---@return string
local function cache_key(cwd)
  local find = require("neotest-golang.lib.find")
  local key_parts = { cwd }

  local dir_stat = vim.uv.fs_stat(cwd)
  key_parts[#key_parts + 1] = dir_stat and (dir_stat.mtime.sec .. ":" .. dir_stat.mtime.nsec) or "?"

  local ok, go_mod = pcall(find.file_upwards, "go.mod", cwd)
  if ok and go_mod then
    local mod_stat = vim.uv.fs_stat(go_mod)
    if mod_stat then
      key_parts[#key_parts + 1] = go_mod .. ":" .. mod_stat.mtime.sec .. ":" .. mod_stat.mtime.nsec
    end
  end

  return table.concat(key_parts, "\0")
end

--- Cap how often neotest redraws the test tree while a run is in flight.
--- The generator still yields between emissions, which is what actually keeps
--- Neovim responsive: chunks that arrive faster than the interval just sit in
--- the nio queue instead of being processed back to back.
---@param spec neotest.RunSpec
---@param interval_ms integer
local function throttle_stream(spec, interval_ms)
  local stream = spec.stream
  if not stream then
    return
  end

  local nio = require("nio")
  local interval_ns = interval_ms * 1e6

  spec.stream = function(data)
    local iterator = stream(data)
    local last_emit = 0

    return function()
      local results = iterator()

      -- Returning nil would end neotest's `for ... in` loop early, so we always
      -- yield a table. Throttling is done by making each call cost at least
      -- `interval_ms` instead.
      local remaining = interval_ns - (vim.uv.hrtime() - last_emit)
      if remaining > 0 then
        nio.sleep(remaining / 1e6)
      end
      last_emit = vim.uv.hrtime()

      return results
    end
  end
end

--- Wrap `build_spec` so every spec this adapter produces gets the fixes above.
---@param adapter table
---@return table
local function patch_adapter(adapter)
  if adapter.__neotest_perf then
    return adapter
  end

  local original_build_spec = adapter.build_spec
  adapter.build_spec = function(args)
    local spec = original_build_spec(args)
    if type(spec) == "table" then
      throttle_stream(spec, STREAM_INTERVAL_MS)
    end
    return spec
  end

  adapter.__neotest_perf = true
  return adapter
end

--- Memoize `go list -json`, which neotest-golang otherwise blocks on per run.
local function patch_golist()
  local cmd = require("neotest-golang.lib.cmd")
  if cmd.__neotest_perf then
    return
  end

  local original = cmd.golist_data
  cmd.golist_data = function(cwd)
    local ok, key = pcall(cache_key, cwd)
    if not ok then
      -- Never let cache bookkeeping break a run.
      return original(cwd)
    end

    local cached = golist_cache[cwd]
    if cached and cached.key == key then
      return cached.data, cached.err
    end

    local data, err = original(cwd)
    golist_cache[cwd] = { key = key, data = data, err = err }
    return data, err
  end

  cmd.__neotest_perf = true
end

function M.setup()
  patch_golist()
end

--- Apply to an already-created adapter instance.
---@param adapter table
---@return table
function M.patch(adapter)
  patch_golist()
  return patch_adapter(adapter)
end

function M.clear_cache()
  golist_cache = {}
end

return M