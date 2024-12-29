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
  },
  {
    "supermaven-inc/supermaven-nvim",
    config = function(_, opts)
      require("supermaven-nvim").setup(opts)
      vim.cmd([[SupermavenToggle]])
    end,
    keys = {
      {
        "<leader>aus",
        function()
          require("supermaven-nvim.api").toggle()
        end,
        desc = "Toggle Supermaven",
      },
    },
  },
}
