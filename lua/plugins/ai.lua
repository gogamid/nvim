return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = true,
    keys = {
      {"<c-s>",      "<CR>",                   ft = "copilot-chat",         desc = "Submit Prompt", remap = true},
      {"<leader>a",  "",                       desc = "+ai",                mode = {"n", "v"}},
      {"<leader>aM", ":CopilotChatModels<CR>", desc = "CopilotChat Models", mode = {"n"}},
      {
        "<leader>ac",
        function() return require("CopilotChat").toggle() end,
        desc = "Toggle (CopilotChat)",
        mode = {"n", "v"},
      },
      {
        "<leader>aq",
        function()
          vim.ui.input({prompt = "Quick Chat: "},
            function(input)
              input = vim.trim(input or "")
              if input ~= "" then
                require("CopilotChat").ask(input,
                  {{selection = require("CopilotChat.select").visual or require("CopilotChat.select").line},})
              else
                vim
                  .notify("No input provided for Quick Chat.", vim.log.levels.WARN)
              end
            end)
        end,
        desc = "Quick Chat (CopilotChat)",
        mode = {"n", "v"},
      },
      {
        "<leader>ap",
        function() require("CopilotChat").select_prompt() end,
        desc = "Prompt actions",
        mode = {"n", "v"},
      },
      {
        "<leader>ad",
        function()
          require("CopilotChat").ask(
            "Please assist with the following diagnostic issue in file #diagnostics:current",
            {selection = require("CopilotChat.select").visual or require("CopilotChat.select").line}
          )
        end,
        desc = "Diagnostics help",
        mode = {"n", "v"},
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
    keys = {
      {
        "<leader>aS",
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
      ignore_filetypes = {"copilot-chat, opencode_ask"},
      color = {
        suggestion_color = "#9198a1",
        cterm = 244,
      },
      disable_inline_completion = false,
    },
  },
  {
    "NickvanDyke/opencode.nvim",
    enabled = false,
    dependencies = {
      -- Recommended for better prompt input, and required to use opencode.nvim's embedded terminal — otherwise optional
      {"folke/snacks.nvim", opts = {input = {enabled = true}}},
    },
    config = function()
      vim.g.opencode_opts = {
        -- Your configuration, if any — see `lua/opencode/config.lua`
      }

      -- Required for `opts.auto_reload`
      vim.opt.autoread = true
    end,
    keys = {
      {"<leader>ao", function() require("opencode").toggle() end, desc = "Toggle embedded opencode"},
      {
        "<leader>as",
        function() require("opencode").ask("@selection: ") end,
        desc = "Ask opencode about selection",
        mode = "v",
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
    },
  }
}
