return {
  {
    "zbirenbaum/copilot.lua",
    keys = {
      {
        "<leader>ua",
        mode = { "n", "v" },
        function()
          local status = vim.g.copilot_status
          local commandName = status and "disable" or "enable"

          vim.cmd("Copilot " .. commandName)
          print("Copilot is " .. commandName .. "d")

          vim.g.copilot_status = not status
        end,
        desc = "Toggle AI completion (Copilot)",
      },
    },
  },
}
