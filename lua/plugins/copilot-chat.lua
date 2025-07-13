return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    keys = {
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt()
        end,
        desc = "Prompt actions",
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
      -- model = "DeepSeek-V3",
      question_header = "## Me", -- Header to use for user questions
      answer_header = "## Broski", -- Header to use for AI answers
      window = {
        title = "",
        layout = "float", -- 'vertical', 'horizontal', 'float', 'replace'
        width = 0.5,
        height = 0.8,
      },
      prompts = {
        DiagnosticFix = {
          prompt = "Please assist with the following diagnostic issue in file",
          description = "Diagnostics help",
        },
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
  },
}
