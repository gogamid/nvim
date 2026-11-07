-- Inline hints for Go constant *usage sites*: gopls' constantValues inlay
-- hint only renders at const declarations. This module watches LSP semantic
-- tokens, treats every `variable [readonly]` token without `definition` as a
-- const usage, resolves the value per const via textDocument/hover, and
-- places an inline virt_text extmark (" = 42").
--
-- Lifecycle, two independent gates:
--   * render gate — buffer changedtick. A text change makes nvim clear and
--     re-emit semantic tokens, so we drop marks and let the redraw rebuild.
--     This gate only ever runs in response to a token event.
--   * value gate — global `state.epoch`, bumped on every *.go save. Const
--     values can change from another file, so snapshots are dropped on next
--     token event per buffer. Marks are NOT cleared: they are updated in
--     place once the new value arrives. A save without edits emits no token
--     events at all, so hints simply stay visible.
--
-- Structure: one state table per buffer, data-oriented — parallel arrays for
-- the waiter arena (no per-token tables), integer ids for const names, a
-- bitset for resolved names, and counters (tick/epoch) instead of walking or
-- clearing structures.
local M = {}

local bit = require("bit")

local ns = vim.api.nvim_create_namespace("usr.goconst_hint")
local group = vim.api.nvim_create_augroup("usr.goconst", { clear = true })

local state = {
  opt = { hl_group = "LspInlayHint", filetypes = { "go" }, max_len = 40 },
  namespace = ns,
  epoch = 0, -- bumped on *.go save; see value gate above
  bufs = {}, -- [bufnr] = bufstate
}
M._state = state -- test hook

-- Bitset helpers (1-based ids, 32-bit chunks).
local function bit_set(t, i)
  local c = math.floor((i - 1) / 32) + 1
  t[c] = bit.bor(t[c] or 0, bit.lshift(1, (i - 1) % 32))
end

local function bit_get(t, i)
  local c = math.floor((i - 1) / 32) + 1
  return bit.band(t[c] or 0, bit.lshift(1, (i - 1) % 32)) ~= 0
end
M._bit_set, M._bit_get = bit_set, bit_get -- test hook

local function new_buf_state(bufnr)
  return {
    bufnr = bufnr,
    enabled = vim.tbl_contains(state.opt.filetypes, vim.bo[bufnr].filetype),
    visible = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
    tick = -1,
    epoch = -1,
    marks = {}, -- [line*2^20+col] = { id = extmark_id, vid = val_id, text = "value", epoch }
    -- value snapshot, reset by the value gate
    names = {},
    values = {},
    name_id = {},
    nvals = 0,
    done = {}, -- bitset: hover finished (value or not) for a val id
    pending = {}, -- [val_id] = true while a hover is in flight
    -- waiter arena: parallel arrays, reset by st.n = 0
    n = 0,
    cap = 32,
    w_buf = {},
    w_line = {},
    w_col = {},
    w_end = {},
    w_vid = {},
  }
end

local function bufstate(bufnr)
  local st = state.bufs[bufnr]
  if not st then
    st = new_buf_state(bufnr)
    state.bufs[bufnr] = st
  end
  return st
end

-- gopls annotates some hover values: "0 // Untyped int.", "math.MaxInt //
-- 9223372036854775807". Strip a trailing line comment, but not one inside a
-- quoted string ("https://...").
local function strip_trailing_comment(value)
  local quoted, quote
  local i = 1
  while i <= #value do
    local ch = value:sub(i, i)
    if quoted then
      if ch == "\\" then
        i = i + 1
      elseif ch == quote then
        quoted = false
      end
    elseif ch == '"' or ch == "'" or ch == "`" then
      quoted, quote = true, ch
    elseif ch == "/" and value:sub(i + 1, i + 1) == "/" then
      return vim.trim(value:sub(1, i - 1))
    end
    i = i + 1
  end
  return vim.trim(value)
end

-- Extract the const value from a gopls hover body (markdown). The relevant
-- line looks like `const X untyped int = 5`; the last match wins. The lazy
-- (.-) swallows the possibly multi-word type up to the first '=', so '='
-- inside string values stays in the capture.
function M.parse_value(text)
  if not text or text == "" then
    return nil
  end
  local value
  for line in text:gmatch("[^\r\n]+") do
    local _, v = line:match("^%s*const%s+[%w_%.]+%s+(.-)=(.+)%s*$")
    if v then
      value = v
    end
  end
  if not value then
    return nil
  end
  value = strip_trailing_comment(value)
  if vim.fn.strcharlen(value) > state.opt.max_len then
    value = vim.fn.strcharpart(value, 0, state.opt.max_len - 1) .. "…"
  end
  return value
end

-- Upsert: update an existing hint in place when the value changed, create it
-- otherwise. Never duplicates on repeated token re-emission.
-- Create/refresh the extmark for a known value. Position is always recorded
-- in the mark registry so a disabled-then-enabled hint can be rebuilt without
-- another hover request.
local function draw(st, m, line, col, end_col, text)
  if not st.visible then
    m.id = nil
    m.text, m.epoch = text, st.epoch
    return
  end
  if m.id then
    vim.api.nvim_buf_set_extmark(st.bufnr, ns, line, end_col, {
      id = m.id,
      virt_text = { { " = " .. text, state.opt.hl_group } },
      virt_text_pos = "inline",
      priority = 60,
    })
  else
    m.id = vim.api.nvim_buf_set_extmark(st.bufnr, ns, line, end_col, {
      virt_text = { { " = " .. text, state.opt.hl_group } },
      virt_text_pos = "inline",
      priority = 60,
    })
  end
  m.text, m.epoch = text, st.epoch
end

local function place(st, line, col, end_col, value, vid)
  local key = line * 0x100000 + col
  local m = st.marks[key]
  if not m then
    m = { line = line, col = col, end_col = end_col }
    st.marks[key] = m
  end
  m.vid = vid
  if m.text == value and m.epoch == st.epoch and (m.id or not st.visible) then
    return
  end
  draw(st, m, line, col, end_col, value)
end

local function push_waiter(st, line, col, end_col, val_id)
  st.n = st.n + 1
  local i = st.n
  if i > st.cap then
    st.cap = st.cap * 2
  end
  st.w_buf[i] = st.bufnr
  st.w_line[i] = line
  st.w_col[i] = col
  st.w_end[i] = end_col
  st.w_vid[i] = val_id
end

local function position_params(bufnr, client, line, col)
  local text = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, true)[1]
  return {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    position = { line = line, character = vim.str_utfindex(text, client.offset_encoding, col, false) },
  }
end

local function resolve(st, id, client, line, col)
  local bufnr, epoch = st.bufnr, state.epoch
  client:request("textDocument/hover", position_params(bufnr, client, line, col), function(err, result)
    if state.bufs[bufnr] ~= st or state.epoch ~= epoch then
      return -- buffer gone, or a save invalidated the snapshot mid-flight
    end
    st.pending[id] = nil
    bit_set(st.done, id)
    if err or not result then
      return -- retried after the next epoch (save)
    end
    local contents = result.contents
    local value = M.parse_value(type(contents) == "table" and contents.value or contents)
    if not value or value == "iota" then
      return -- no usable value; retried after the next epoch
    end
    st.values[id] = value
    for i = 1, st.n do
      if st.w_vid[i] == id then
        if vim.api.nvim_buf_is_valid(bufnr) then
          place(st, st.w_line[i], st.w_col[i], st.w_end[i], value, id)
        end
        st.w_vid[i] = 0
      end
    end
  end)
end

local function value_gate(st)
  st.epoch = state.epoch
  st.values = {}
  st.name_id = {}
  st.nvals = 0
  st.done = {}
  st.pending = {}
  st.n = 0
end

local function render_gate(st)
  st.tick = vim.b[st.bufnr].changedtick
  st.marks = {}
  st.n = 0 -- waiters of the old version are stale
  vim.api.nvim_buf_clear_namespace(st.bufnr, ns, 0, -1)
end

-- LspTokenUpdate callback. Fires for every semantic token of every server,
-- re-fires per gopls refresh; filtered to opt.filetypes.
function M._on_token(args)
  local bufnr = args.buf == 0 and vim.api.nvim_get_current_buf() or args.buf
  -- lazy: the module may be loaded (LspAttach) after this buffer's FileType
  -- event already fired, so its state may not exist yet
  local st = bufstate(bufnr)
  if not st.enabled then
    return
  end
  local token = args.data and args.data.token
  if
    not token
    or token.type ~= "variable"
    or not token.modifiers
    or not token.modifiers.readonly
    or token.modifiers.definition
  then
    return
  end
  if st.epoch ~= state.epoch then
    value_gate(st)
  end
  if st.tick ~= vim.b[bufnr].changedtick then
    render_gate(st)
  end

  if token.end_line and token.end_line ~= token.line then
    return -- multi-line token: end_col refers to another line; not an identifier
  end
  local line, col, end_col = token.line, token.start_col, token.end_col
  if end_col <= col then
    return
  end
  local m = st.marks[line * 0x100000 + col]
  if m and m.epoch == st.epoch then
    return -- already rendered from current values
  end

  local name = vim.api.nvim_buf_get_text(bufnr, line, col, line, end_col, {})[1]
  if not name or name == "" or name == "iota" then
    return
  end

  local id = st.name_id[name]
  if not id then
    st.nvals = st.nvals + 1
    id = st.nvals
    st.names[id] = name
    st.name_id[name] = id
  end

  local value = st.values[id]
  if value then
    place(st, line, col, end_col, value, id)
    return
  end
  if st.pending[id] then
    -- same const again while its hover is in flight: join the waiter list so
    -- the response places this position too
    push_waiter(st, line, col, end_col, id)
    return
  end
  if bit_get(st.done, id) then
    -- hover already came back without a usable value; retried next epoch
    return
  end
  st.pending[id] = true
  push_waiter(st, line, col, end_col, id)
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if not client then
    st.pending[id] = nil
    return
  end
  resolve(st, id, client, line, col)
end

-- Force a re-resolve on next token refresh; marks are kept and updated in
-- place. Mostly useful as a manual escape hatch.
function M.clear_cache()
  state.epoch = state.epoch + 1
end

-- Mirror vim.lsp.inlay_hint visibility (the <leader>uh snacks toggle calls
-- vim.lsp.inlay_hint.enable). Positions and resolved values are kept, so
-- re-enabling redraws instantly without new hover requests.
function M.sync_visibility(enable, filter)
  local target = filter and filter.bufnr
  if target == 0 then
    target = vim.api.nvim_get_current_buf()
  end
  for buf, st in pairs(state.bufs) do
    if target == nil or buf == target then
      st.visible = enable
      if enable then
        for _, m in pairs(st.marks) do
          if not m.id and m.text then
            draw(st, m, m.line, m.col, m.end_col, m.text)
          end
        end
      elseif vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        for _, m in pairs(st.marks) do
          m.id = nil
        end
      end
    end
  end
end

-- Hook the one API the toggle uses. Wrapping is deliberate: nvim has no
-- event for inlay-hint enable/disable.
if not state.wrapped_enable then
  state.wrapped_enable = true
  local orig_enable = vim.lsp.inlay_hint.enable
  vim.lsp.inlay_hint.enable = function(enable, filter)
    orig_enable(enable, filter)
    M.sync_visibility(enable ~= false, filter)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(args)
    local st = bufstate(args.buf)
    st.enabled = vim.tbl_contains(state.opt.filetypes, vim.bo[args.buf].filetype)
  end,
})

-- Bump the value gate. No buffer state is touched here: a save without edits
-- produces no token events and no redraw, so hints and snapshots stay as-is.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = group,
  pattern = "*.go",
  callback = function()
    state.epoch = state.epoch + 1
  end,
})

vim.api.nvim_create_autocmd({ "LspDetach", "BufWipeout" }, {
  group = group,
  callback = function(args)
    local st = state.bufs[args.buf]
    if not st then
      return
    end
    if vim.api.nvim_buf_is_valid(args.buf) then
      vim.api.nvim_buf_clear_namespace(args.buf, ns, 0, -1)
    end
    state.bufs[args.buf] = nil
  end,
})

vim.api.nvim_create_autocmd("LspTokenUpdate", { group = group, callback = M._on_token })

function M.setup(opts)
  state.opt = vim.tbl_deep_extend("force", state.opt, opts or {})
end

return M
