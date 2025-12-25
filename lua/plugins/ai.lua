-- Store last selected CLI tool/session in memory
vim.g.last_session_id = nil
return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = true,
    keys = {
      { "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
      { "<leader>aM", ":CopilotChatModels<CR>", desc = "CopilotChat Models", mode = { "n" } },
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
    "olimorris/codecompanion.nvim",
    enabled = false,
    keys = {
      {
        "<leader>aa",
        ":CodeCompanionChat Toggle<CR>",
        mode = { "n", "v" },
        { noremap = true, silent = true, desc = "CodeCompanion Toggle" },
      },
      {
        "ga",
        ":CodeCompanionChat Add<CR>",
        mode = { "v" },
        { noremap = true, silent = true, desc = "Add selection to CodeCompanionChat" },
      },
    },
    opts = {
      strategies = {
        chat = {
          -- adapter = "githubmodels",
          -- model = "grok-code",
          -- adapter = "opencode",
        },
        inline = {
          -- adapter = "opencode",
          -- adapter = "githubmodels",
          -- model = "grok-code",
        },
      },
      display = {
        chat = {
          window = {
            layout = "float",
          },
        },
      },
      adapters = {
        http = {
          acp = {
            gemini_cli = function()
              return require("codecompanion.adapters").extend("gemini_cli", {
                defaults = {
                  auth_method = "oauth-personal", -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
                },
                env = {
                  api_key = os.getenv("GEMINI_API_KEY"),
                },
              })
            end,
            opencode = {
              name = "opencode",
              formatted_name = "OpenCode",
              type = "acp",
              roles = {
                llm = "assistant",
                user = "user",
              },
              opts = {
                vision = true,
              },
              commands = {
                default = {
                  "opencode acp",
                },
                grok = {
                  "opencode acp",
                  "--model opencode/grok-code",
                },
              },
              defaults = {
                mcpServers = {},
                timeout = 20000, -- 20 seconds
              },
              parameters = {
                protocolVersion = 1,
                clientCapabilities = {
                  fs = { readTextFile = true, writeTextFile = true },
                },
                clientInfo = {
                  name = "CodeCompanion.nvim",
                  version = "1.0.0",
                },
              },
              handlers = {
                ---@param self CodeCompanion.ACPAdapter
                ---@return boolean
                setup = function(self)
                  return true
                end,

                ---@param self CodeCompanion.ACPAdapter
                ---@param messages table
                ---@param capabilities table
                ---@return table
                form_messages = function(self, messages, capabilities)
                  return require("codecompanion.adapters.acp.helpers").form_messages(self, messages, capabilities)
                end,

                ---Function to run when the request has completed. Useful to catch errors
                ---@param self CodeCompanion.ACPAdapter
                ---@param code number
                ---@return nil
                on_exit = function(self, code) end,
              },
            },
          },
          opts = {},
        },
      },
    },
    config = function(_, opts)
      require("codecompanion").setup(opts)

      vim.cmd([[cab cc CodeCompanion]])
      vim.api.nvim_create_autocmd("FileType", {
        desc = "Toggle CodeCompanion with q",
        pattern = {
          "codecompanion",
        },
        callback = function(event)
          vim.bo[event.buf].buflisted = false
          vim.schedule(function()
            vim.keymap.set("n", "q", function()
              vim.cmd("CodeCompanionChat Toggle")
            end, {
              buffer = event.buf,
              silent = true,
              desc = "Toggle CodeCompanion",
            })
          end)
        end,
      })
    end,
  },
  {
    "folke/sidekick.nvim",
    enabled = false,
    opts = {
      cli = {
        mux = {
          backend = "tmux",
          create = "window",
          enabled = false,
        },
        win = {
          layout = "float",
          float = {
            width = 0.6,
            height = 0.7,
          },
        },
      },
      nes = {
        enabled = false,
      },
    },
    keys = {
      {
        "<leader>as",
        function()
          require("sidekick.cli").select({
            filter = { name = "opencode" },
            cb = function(state)
              local dirName = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
              local cwd = vim.fs.root(0, { "service.yaml", ".git", dirName })
              vim.cmd("tcd " .. cwd)
              if state then
                require("sidekick.cli.state").attach(state, { show = true, focus = true })
                if state.session then
                  vim.g.last_session_id = state.session.id
                end
              end
            end,
          })
        end,
        desc = "Select or create CLI",
      },
      {
        "<c-.>",
        function()
          require("sidekick.cli").toggle({ filter = { session = vim.g.last_session_id } })
        end,
        desc = "Sidekick Toggle Last Session",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt()
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
    },
  },
  {
    "yetone/avante.nvim",
    build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    event = "VeryLazy",
    enabled = false,
    opts = {
      provider = "gemini",
      mode = "legacy", -- Switch from "agentic" to "legacy"
      providers = {
        copilot = nil,
        ollama = {
          model = "gpt-oss:latest",
        },
        gemini = {
          -- @see https://ai.google.dev/gemini-api/docs/models/gemini
          model = "gemini-2.5-pro",
          timeout = 30000, -- timeout in milliseconds
          temperature = 0, -- adjust if needed
          max_tokens = 4096,
        },
      },
      selection = {
        hint_display = "none",
      },
      behaviour = {
        auto_set_keymaps = true,
        enable_token_counting = false,
      },
    },
    config = function(_, opts)
      require("avante").setup(opts)
      vim.cmd("AvanteSwitchProvider gemini")
    end,
    keys = {
      {
        "<leader>ad",
        function()
          require("avante.api").ask({
            new_chat = true,
            question = "Please shortly explain the following diagnostic issue in file @diagnostics",
            project_root = vim.fs.root(0, { "service.yaml", ".git" }) or vim.fn.getcwd(),
          })
        end,
        mode = { "n", "v" },
        desc = "Diagnostics help",
      },
      {
        "<leader>aq",
        function()
          require("avante.api").ask({
            new_chat = true,
            floating = true,
            project_root = vim.fs.root(0, { "service.yaml", ".git" }) or vim.fn.getcwd(),
          })
        end,
        mode = { "n", "v" },
        desc = "Quick Chat",
      },
    },
  },
  {
    "sourcegraph/amp.nvim",
    branch = "main",
    lazy = false,
    opts = { auto_start = true, log_level = "info" },
  },
}
