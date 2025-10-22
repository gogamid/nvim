-- Store last selected CLI tool/session in memory
vim.g.last_session_id = nil
return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = false,
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
    enabled = false,
    keys = {
      {
        "<leader>aS",
        function()
          require("supermaven-nvim.api").toggle()
        end,
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
    },
    config = function(_, opts)
      require("supermaven-nvim").setup(opts)
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    enabled = false,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
      { "nvim-lua/plenary.nvim" },
    },
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
          adapter = "githubmodels",
          model = "grok-code",
          -- adapter = "opencode",
        },
        inline = {
          adapter = "githubmodels",
          model = "grok-code",
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
                  auth_method = "gemini-api-key", -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
                },
                env = {
                  api_key = os.getenv("GEMINI_API_KEY"),
                },
              })
            end,
            opencode = {
              name = "opencode",
              formatted_name = "Opencode",
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
              },
              defaults = {
                mcpServers = {},
                timeout = 20000, -- 20 seconds
              },
              env = {},
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

                ---Manually handle authentication
                ---@param self CodeCompanion.ACPAdapter
                ---@return boolean
                auth = function(self)
                  return true
                end,

                ---@param self CodeCompanion.ACPAdapter
                ---@param messages table
                ---@param capabilities table
                ---@return table
                form_messages = function(self, messages, capabilities)
                  local helpers = require("codecompanion.adapters.acp.helpers")
                  return helpers.form_messages(self, messages, capabilities)
                end,

                ---Function to run when the request has completed. Useful to catch errors
                ---@param self CodeCompanion.ACPAdapter
                ---@param code number
                ---@return nil
                on_exit = function(self, code)
                  if code ~= 0 then
                    vim.notify("OpenCode ACP exited with code " .. code, vim.log.levels.ERROR)
                  end
                end,
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
    -- HEAD is now at c262b25 fix(qwen): set `mux_focus = true` since qwen doesnt process input if unfocused. Fixes #104
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
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      provider = "copilot",
      selection = {
        hint_display = "none",
      },
      behaviour = {
        -- auto_set_keymaps = false,
      },
      acp_providers = {
        ["opencode"] = {
          command = "opencode",
          args = { "acp" },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-mini/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "stevearc/dressing.nvim", -- for input provider dressing
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  cmd = {
    "AvanteAsk",
    "AvanteBuild",
    "AvanteChat",
    "AvanteClear",
    "AvanteEdit",
    "AvanteFocus",
    "AvanteHistory",
    "AvanteModels",
    "AvanteRefresh",
    "AvanteShowRepoMap",
    "AvanteStop",
    "AvanteSwitchProvider",
    "AvanteToggle",
  },
  keys = {
    { "<leader>aa", "<cmd>AvanteAsk<CR>", desc = "Ask Avante" },
    { "<leader>ac", "<cmd>AvanteChat<CR>", desc = "Chat with Avante" },
    { "<leader>ae", "<cmd>AvanteEdit<CR>", desc = "Avante Edit Settings" },
    { "<leader>af", "<cmd>AvanteFocus<CR>", desc = "Avante Focus Mode" },
    { "<leader>ah", "<cmd>AvanteHistory<CR>", desc = "Avante History" },
    { "<leader>am", "<cmd>AvanteModels<CR>", desc = "Select Avante Model" },
    { "<leader>an", "<cmd>AvanteChatNew<CR>", desc = "New Avante Chat" },
    { "<leader>ap", "<cmd>AvanteSwitchProvider<CR>", desc = "Switch Avante Provider" },
    { "<leader>ar", "<cmd>AvanteRefresh<CR>", desc = "Refresh Avante" },
    { "<leader>as", "<cmd>AvanteStop<CR>", desc = "Stop Avante" },
    { "<leader>at", "<cmd>AvanteToggle<CR>", desc = "Toggle Avante" },
  },
}
