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
        desc = "Prompt actions",
      },
      {
        "<leader>as",
        function()
          local input = vim.fn.input("Perplexity: ")
          if input ~= "" then
            require("CopilotChat").ask(input, {
              agent = "perplexityai",
              selection = false,
            })
          end
        end,
        desc = "Perplexity Search",
        mode = { "n", "v" },
      },
      {
        "<leader>ad",
        function()
          require("CopilotChat").ask("Please assist with the following diagnostic issue in file", {
            selection = require("CopilotChat.select").line,
          })
        end,
        desc = "Diagnostics help",
        mode = { "n", "v" },
      },
    },
    opts = {
      model = "gemini-2.0-flash-001",
      question_header = "## Me", -- Header to use for user questions
      answer_header = "## Broski", -- Header to use for AI answers
      window = {
        title = "",
        layout = "float", -- 'vertical', 'horizontal', 'float', 'replace'
        width = 0.50,
        height = 0.9,
      },
      prompts = {
        DiagFix = {
          prompt = "Please assist with the following diagnostic issue in file",
          description = "Diagnostics help",
        },
        EnGrammarFix = {
          prompt = "Correct grammar",
          system_prompt = "You are very good at writing stuff",
          -- mapping = "<leader>ccmc",
          -- description = "My custom prompt description",
        },
        DeGrammarFix = {
          prompt = "Korriegiere Grammatik",
          system_prompt = "Du bist sehr gut im Schreiben von Texten",
          -- mapping = "<leader>ccmc",
          -- description = "My custom prompt description",
        },
      },
    },
  },
}
