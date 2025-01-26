return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    keys = {
      {
        "<leader>ap",
        function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.snacks").pick(actions.prompt_actions(), {
            layout = {
              preset = "dropdown",
            },
          })
        end,
        desc = "CopilotChat - Prompt actions",
      },
    },
    opts = {
      question_header = "## Me", -- Header to use for user questions
      answer_header = "## Broski", -- Header to use for AI answers
      window = {
        title = "",
        layout = "float", -- 'vertical', 'horizontal', 'float', 'replace'
        width = 0.65,
        height = 0.9,
      },
    },
  },
}
