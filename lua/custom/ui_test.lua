local M = {}

function M.run_cypress()
  local Snacks = require("snacks")
  local cmd = "pnpm cypress run --component --spec " .. vim.fn.expand("%")
  local win = Snacks.terminal(cmd, {
    interactive = false,
    bo = {
      filetype = "cypress",
    },
    wo = {},
    keys = {
      q = "hide",
      term_normal = {
        "<esc>",
        function(self)
          self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
          if self.esc_timer:is_active() then
            self.esc_timer:stop()
            vim.cmd("stopinsert")
          else
            self.esc_timer:start(200, 0, function() end)
            return "<esc>"
          end
        end,
        mode = "t",
        expr = true,
        desc = "Double escape to normal mode",
      },
    },
  })
end

return M
