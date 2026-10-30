-- smart-splits.nvim v3 backend for Rex (https://superlogical.com/rex).

local Direction = require("smart-splits.types").Direction

local M = {}

local split_directions = {
  [Direction.left] = "left",
  [Direction.right] = "right",
  [Direction.up] = "above",
  [Direction.down] = "below",
}

local function session_id()
  return vim.env.REX_SESSION
end

local function rex_exec(args)
  local cmd = { "rex" }
  vim.list_extend(cmd, args)
  local ok, handle = pcall(vim.system, cmd, { text = true })
  if not ok or not handle then
    return nil, 1
  end

  local result = handle:wait()
  if result.code == 0 then
    return result.stdout or "", 0
  end
  return result.stderr or "", result.code
end

local function get_view()
  local sid = session_id()
  if not sid then
    return nil
  end

  local out, code = rex_exec({ "session", "inspect", sid, "--json" })
  if code ~= 0 or not out or out == "" then
    return nil
  end

  local ok, view = pcall(vim.json.decode, out)
  if not ok or type(view) ~= "table" then
    return nil
  end
  return view
end

---The window that owns the block Neovim runs in. Rex keys can arrive while
---another window is active in the app, so use the block's window, not
---`active_window_id`.
local function window_for_block(view, block_id)
  for _, win in ipairs(view.windows or {}) do
    for _, layer in ipairs(win.layers or {}) do
      for _, blk in ipairs(layer.blocks or {}) do
        if blk.block_id == block_id then
          return win
        end
      end
    end
  end
end

local function find_block_node(node, block_id)
  if type(node) ~= "table" then
    return nil
  end
  if node.block_id == block_id then
    return node
  end
  if node.split then
    return find_block_node(node.split.before, block_id) or find_block_node(node.split.after, block_id)
  end
end

local function first_block(node)
  if type(node) ~= "table" then
    return nil
  end
  if node.block_id then
    return node.block_id
  end
  if node.split then
    return first_block(node.split.before) or first_block(node.split.after)
  end
end

---Find the deepest split on the path to `block_id` whose orientation matches
---`want` ("horizontal" for left/right, "vertical" for up/down).
---@return table|nil split, number[]|nil rect
local function find_split_on_path(node, block_id, want)
  local split = type(node) == "table" and node.split or nil
  if not split then
    return nil
  end

  local child
  if find_block_node(split.before, block_id) then
    child = split.before
  elseif find_block_node(split.after, block_id) then
    child = split.after
  else
    return nil
  end

  local deeper, rect = find_split_on_path(child, block_id, want)
  if deeper then
    return deeper, rect
  end
  if split.direction == want then
    return split, node.rect
  end
end

---Find the tiled block node and its layer in `win`.
local function tiled_block(win, block_id)
  for _, layer in ipairs(win.layers or {}) do
    if layer.kind == "tiled" and layer.layout then
      local node = find_block_node(layer.layout, block_id)
      if node then
        return node, layer
      end
    end
  end
end

local function api_call(method, payload)
  local args = { "api", "call", "-s", session_id(), method }
  if payload then
    table.insert(args, vim.json.encode(payload))
  end
  return rex_exec(args)
end

local function revision_of(out, code)
  if code ~= 0 or not out or out == "" then
    return nil
  end
  local ok, decoded = pcall(vim.json.decode, out)
  if ok and type(decoded) == "table" then
    return decoded.revision
  end
end

local function split_block(direction)
  local name = split_directions[direction]
  if not name then
    return false
  end
  local _, code = rex_exec({ "split", "-s", session_id(), "--split=" .. name, "--json" })
  return code == 0
end

function M.detect()
  local sid = session_id()
  return sid ~= nil and sid ~= "" and vim.fn.executable("rex") == 1
end

function M.move(direction, opts)
  opts = opts or {}
  local view = get_view()
  if not view then
    return false
  end

  local win = window_for_block(view, vim.env.REX_BLOCK)
  if not win then
    return false
  end
  local baseline = view.revision or 0

  -- focus_direction acts on the active window. If the app shows another
  -- window, bring Neovim's window forward first.
  if view.active_window_id ~= win.window_id then
    local out, code = api_call("session.focus_window", { window_id = win.window_id })
    baseline = revision_of(out, code) or baseline
  end

  local out, code = api_call("session.focus_direction", {
    direction = direction,
    wrap = opts.at_edge == "wrap",
  })
  if code ~= 0 then
    return false
  end

  local revision = revision_of(out, code)
  if revision ~= nil and revision > baseline then
    return true
  end

  if opts.at_edge == "split" then
    return split_block(direction)
  end
  return false
end

function M.resize(direction, opts)
  opts = opts or {}
  local view = get_view()
  local win = view and window_for_block(view, vim.env.REX_BLOCK)
  if not win or not win.focused_block_id then
    return false
  end

  local node, layer = tiled_block(win, win.focused_block_id)
  if not node then
    return false
  end

  local horizontal = direction == Direction.left or direction == Direction.right
  local want = horizontal and "horizontal" or "vertical"
  local split, split_rect = find_split_on_path(layer.layout, win.focused_block_id, want)
  if not split then
    return false
  end

  -- Convert Neovim cells to a fraction of the split's own extent.
  local amount = opts.amount or 3
  local block_rect = node.rect or { 0, 0, 1, 1 }
  split_rect = split_rect or { 0, 0, 1, 1 }
  local region
  if horizontal then
    region = vim.o.columns * split_rect[3] / math.max(block_rect[3], 1e-6)
  else
    region = vim.o.lines * split_rect[4] / math.max(block_rect[4], 1e-6)
  end

  local grow_before = direction == Direction.right or direction == Direction.down
  local delta = amount / math.max(region, 1)
  local ratio = math.min(math.max(split.ratio + (grow_before and delta or -delta), 0.05), 0.95)
  if math.abs(ratio - split.ratio) < 1e-4 then
    return false
  end

  local _, code = api_call("session.resize_pane", {
    direction = want,
    before_block_id = first_block(split.before),
    after_block_id = first_block(split.after),
    ratio = ratio,
  })
  return code == 0
end

M.name = "rex"
M.protocol_version = "3.0.0"

return M
