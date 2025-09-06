return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = true,
    keys = {
      { "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      { "<leader>aM", ":CopilotChatModels<CR>", desc = "CopilotChat Models", mode = { "n" } },
      {
        "<leader>aa",
        function() return require("CopilotChat").toggle() end,
        desc = "Toggle (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>aq",
        function()
          vim.ui.input({ prompt = "Quick Chat: " }, function(input)
            input = vim.trim(input or "")
            if input ~= "" then
              require("CopilotChat").ask(input, {
                { selection = require("CopilotChat.select").visual or require("CopilotChat.select").line },
              })
            else
              vim.notify("No input provided for Quick Chat.", vim.log.levels.WARN)
            end
          end)
        end,
        desc = "Quick Chat (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>ap",
        function() require("CopilotChat").select_prompt() end,
        desc = "Prompt actions",
        mode = { "n", "v" },
      },
      {
        "<leader>ad",
        function()
          require("CopilotChat").ask(
            "Please assist with the following diagnostic issue in file #diagnostics:current",
            { selection = require("CopilotChat.select").visual or require("CopilotChat.select").line }
          )
        end,
        desc = "Diagnostics help",
        mode = { "n", "v" },
      },
    },
    opts = {
      model = "claude-sonnet-4",
      temperature = 0.1,
      auto_insert_mode = false,
      headers = {
        user = "👤: ",
        assistant = "🤖: ",
        tool = "🔧: ",
      },
      window = {
        title = "",
        layout = "float", -- 'vertical', 'horizontal', 'float', 'replace'
        width = 0.5,
        height = 0.8,

        -- layout = "horizontal", -- 'vertical', 'horizontal', 'float'
        -- height = 0.3,
      },
      selection = function(source)
        return require("CopilotChat.select").visual(source) or require("CopilotChat.select").line(source)
      end,
      prompts = {
        ReviewCode = {
          prompt = "Review code Feedback",
          system_prompt = [[You are a developer tasked with providing detailed, constructive feedback on code snippets across various programming languages. Your responses should focus on improving code quality, readability, and adherence to best practices.

Here are the rules you must follow:
- Analyze the code for potential errors and suggest corrections.
- Offer improvements on code efficiency and maintainability.
- Mention line numbers when referring to the code
- Highlight any deviations from standard coding practices.
- Encourage the use of comments or documentation where necessary.
- Suggest better variable, function, or class names if you see fit.
- Detail alternative approaches and their advantages when relevant.
- When possible, refer to official guidelines or documentation to support your recommendations.]],
          -- mapping = "<leader>ccmc",
          -- description = "My custom prompt description",
        },
        ReviewVueCode = {
          prompt = "Review Vue code",
          system_prompt = [[You are a Vue 3 expert specializing in the Composition API. Provide expert-level insights, solutions, and best practices for modern Vue development.

Here are some rules:
- Use Vue 3 with Composition API and <script setup> syntax.
- Demonstrate effective use of Composition API features (ref, reactive, computed, watch).
- Implement TypeScript when applicable, with clear type definitions.
- Highlight important considerations (reactivity, lifecycle, component design).
- Avoid adding code comments unless necessary.
- Provide concise code snippets and real-world examples.
- Explain rationale behind recommendations and solutions.
- Mention browser compatibility issues when relevant.
- Avoid adding third-party libraries unless necessary.
- Use modern ES6+ syntax and clear naming conventions.
- Link to official Vue 3 documentation for complex topics.
- Showcase efficient state management and performance optimization techniques.]],
          -- mapping = "<leader>ccmc",
          -- description = "My custom prompt description",
        },
      },
    },
    config = function(_, opts)
      require("CopilotChat").setup(opts)

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
          vim.opt_local.conceallevel = 0
        end,
      })
    end,
  },
  {
    "supermaven-inc/supermaven-nvim",
    keys = {
      {
        "<leader>ass",
        function() require("supermaven-nvim.api").toggle() end,
        desc = "Toggle Supermaven",
      },
    },
    opts = {
      keymaps = {
        accept_suggestion = "<C-i>",
        accept_word = "<C-o>",
        clear_suggestion = "<C-x>",
      },
      ignore_filetypes = { "copilot-chat, opencode_ask" },
      color = {
        suggestion_color = "#9198a1",
        cterm = 244,
      },
      disable_inline_completion = false,
    },
  },
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      -- Recommended for better prompt input, and required to use opencode.nvim's embedded terminal — otherwise optional
      { "folke/snacks.nvim", opts = { input = { enabled = true } } },
    },
    opts = {
      -- Your configuration, if any — see lua/opencode/config.lua
    },
    keys = {
      { "<leader>Aa", function() require("opencode").toggle() end, desc = "Toggle embedded opencode" },
      {
        "<leader>As",
        function() require("opencode").ask("@selection: ") end,
        desc = "Ask opencode about selection",
        mode = "v",
      },
      { "<leader>An", function() require("opencode").command("session_new") end, desc = "New Opencode session" },
    },
  },
}
