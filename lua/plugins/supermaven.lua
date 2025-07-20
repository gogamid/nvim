return {
  {
    "supermaven-inc/supermaven-nvim",
    opts = {
      keymaps = {
        accept_suggestion = "<C-o>",
        clear_suggestion = "<C-x>",
        -- accept_word = "<Tab>",
      },
      ignore_filetypes = { "copilot-chat" },
      color = {
        suggestion_color = "#9198a1",
        cterm = 244,
      },
      disable_inline_completion = vim.g.ai_cmp,
    },
    keys = {
      {
        "<leader>ast",
        function()
          require("supermaven-nvim.api").toggle()
          if require("supermaven-nvim.api").is_running() then
            print("supermaven running")
          else
            print("supermaven stopped")
          end
        end,
        desc = "Toggle Supermaven",
      },
    },
  },
}
