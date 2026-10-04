local M = {}

function M.resolve(_, src)
  local mime, payload = src:match("^data:(image/[^;]+);base64,(.+)$")
  if not mime then
    return nil
  end

  -- Snacks URL-decodes the source before calling resolve, replacing '+' with spaces.
  mime = mime:gsub(" ", "+")
  payload = payload:gsub(" ", "+")
  local extension = mime == "image/svg+xml" and "svg" or mime:match("^image/([%w]+)$")
  assert(extension, "Unsupported embedded image type: " .. mime)
  local data = vim.base64.decode(payload)
  local directory = vim.fn.stdpath("cache") .. "/snacks/image"
  vim.fn.mkdir(directory, "p")
  local path = directory .. "/" .. vim.fn.sha256(data) .. "-embedded." .. extension
  if vim.fn.filereadable(path) == 0 then
    local file = assert(io.open(path, "wb"))
    local ok, err = file:write(data)
    file:close()
    assert(ok, err)
  end
  return path
end

return M
