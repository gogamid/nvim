_G.err = function(msg, title)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.ERROR, { title = title })
  end)
end

_G.info = function(msg, title)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.INFO, { title = title })
  end)
end
require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
