return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = true,
    keys = {
      { "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
      { "<leader>aM", ":CopilotChatModels<CR>", desc = "CopilotChat Models" },
      {
        "<leader>ac",
        function()
          return require("CopilotChat").toggle()
        end,
        desc = "Toggle (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>aq",
        function()
          vim.ui.input({ prompt = "Quick Chat: " }, function(input)
            input = vim.trim(input or "")
            if input ~= "" then
              require("CopilotChat").ask(
                input,
                { { selection = require("CopilotChat.select").visual or require("CopilotChat.select").line } }
              )
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
        function()
          require("CopilotChat").select_prompt()
        end,
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
      providers = {
        copilot = {
          disabled = true,
        },
        github_models = {
          disabled = true,
        },
        github_embeddings = {
          disabled = true,
        },
        gemini = {

          prepare_input = function(inputs, opts)
            return require("CopilotChat.config.providers").copilot.prepare_input(inputs, opts)
          end,

          prepare_output = function(output)
            return require("CopilotChat.config.providers").copilot.prepare_output(output)
          end,

          get_headers = function()
            local gemini_key = os.getenv("GEMINI_API_KEY")
            return {
              ["Authorization"] = "Bearer " .. gemini_key,
            }, nil
          end,

          get_models = function(headers)
            local response, err =
              require("CopilotChat.utils").curl_get("https://generativelanguage.googleapis.com/v1beta/openai/models", {
                headers = headers,
                json_response = true,
              })

            if err then
              error(err)
            end

            return vim.tbl_map(function(model)
              return {
                id = model.id,
                name = model.id,
              }
            end, response.body.data)
          end,

          embed = function(inputs, headers)
            local response, err = require("CopilotChat.utils").curl_post(
              "https://generativelanguage.googleapis.com/v1beta/openai/embeddings",
              {
                headers = headers,
                json_request = true,
                json_response = true,
                body = {
                  input = inputs,
                  model = "gemini-embedding-001",
                },
              }
            )

            if err then
              error(err)
            end

            local data = {}
            for i, embed in ipairs(response.body.data) do
              table.insert(data, {
                index = i - 1,
                embedding = embed.embedding,
                object = embed.object,
              })
            end

            return data
          end,

          get_url = function()
            return "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
          end,
        },
      },
      model = "models/gemini-2.5-flash",
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
    enabled = true,
    keys = {
      {
        "<leader>uC",
        function()
          require("supermaven-nvim.api").toggle()
        end,
        desc = "Toggle Supermaven Completion",
      },
      {
        "<C-i>",
        function()
          require("supermaven-nvim.completion_preview").on_accept_suggestion()
        end,
        mode = { "i" },
        remap = true,
        silent = true,
        desc = "Accept next block",
      },
      {
        "<C-o>",
        function()
          require("supermaven-nvim.completion_preview").on_accept_suggestion_word()
        end,
        mode = { "i" },
        remap = true,
        silent = true,
        desc = "Accept next word",
      },
      {
        "<C-x>",
        function()
          require("supermaven-nvim.completion_preview").on_dispose_inlay()
        end,
        mode = { "i" },
        remap = true,
        silent = true,
        desc = "Clear completion",
      },
    },
    opts = {
      keymaps = {
        -- accept_suggestion = "<C-o>",
        -- accept_word = "<C-i>",
        -- clear_suggestion = "<C-x>",
      },
      ignore_filetypes = { "copilot-chat, opencode_ask", "snacks_picker_input" },
      color = {
        suggestion_color = "#9198a1",
        cterm = 244,
        oyster = "#F9F4EA",
        terracotta = "#C47457",
        truffle = "#605F4B",
        sand = "#CDAD85",
        sage = "#9C9E80",
        copper = "#B68036",
        rosewater = "T",
        flamingo = "T",
        pink = "T",
        mauve = "T",
        red = "T",
        maroon = "T",
        peach = "T",
        yellow = "T",
        green = "T",
        teal = "T",
        sky = "T",
        sapphire = "T",
        blue = "T",
        lavender = "T",
        text = "T",
        subtext1 = "T",
        subtext0 = "T",
        overlay2 = "T",
        overlay1 = "T",
        overlay0 = "T",
        surface2 = "T",
        surface1 = "T",
        surface0 = "T",
        base = "T",
        mantle = "T",
        crust = "T",
        none = "T",
      },
      disable_inline_completion = false,
      disable_keymaps = true,
    },
    config = function(_, opts)
      require("supermaven-nvim").setup(opts)
    end,
  },
  {
    "sourcegraph/amp.nvim",
    branch = "main",
    lazy = false,
    opts = { auto_start = true, log_level = "info" },
  },
}
