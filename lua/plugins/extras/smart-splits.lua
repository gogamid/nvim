return {
  {
    "mrjones2014/smart-splits.nvim",
    config = function()
      -- Rex multiplexer backend for smart-splits v3.
      local rex = require("modules.smart_splits_rex")
      local smart_splits = require("smart-splits")

      smart_splits.setup({
        mux = { backend = rex.detect() and rex or nil },
      })

      local directions = { h = "left", j = "down", k = "up", l = "right" }
      for key, direction in pairs(directions) do
        vim.keymap.set("n", "<C-" .. key .. ">", smart_splits["move_cursor_" .. direction], {
          desc = "Move to " .. direction .. " split",
        })
        vim.keymap.set("v", "<C-" .. key .. ">", smart_splits["resize_" .. direction], {
          desc = "Resize split " .. direction,
        })
      end
    end,
  },
}
