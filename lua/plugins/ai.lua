local tabnine_enterprise_host = "https://tabnine.stackit.run"
return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
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
  -- {
  --   "codota/tabnine-nvim",
  --   enabled = false,
  --   build = "./dl_binaries.sh " .. tabnine_enterprise_host .. "/update",
  --   keys = {
  --     { "<leader>ua", "<cmd>TabnineToggle<CR>", desc = "Toggle Tabnine" },
  --   },
  --   config = function()
  --     require("tabnine").setup({
  --       disable_auto_comment = true,
  --       accept_keymap = "<C-o>",
  --       dismiss_keymap = "<C-c>",
  --       debounce_ms = 800,
  --       suggestion_color = { gui = "#808080", cterm = 244 },
  --       codelens_color = { gui = "#808080", cterm = 244 },
  --       codelens_enabled = false,
  --       exclude_filetypes = { "TelescopePrompt", "NvimTree" },
  --       log_file_path = nil, -- absolute path to Tabnine log file
  --       tabnine_enterprise_host = tabnine_enterprise_host,
  --       ignore_certificate_errors = false,
  --     })
  --   end,
  -- },
  -- { -- lua alternative to the official codeium.vim plugin https://github.com/Exafunction/codeium.vim
  --   "monkoose/neocodeium",
  --   event = "InsertEnter",
  --   cmd = "NeoCodeium",
  --   opts = {
  --     silent = true,
  --     show_label = false, -- signcolumn label for number of suggestions
  --
  --     filetypes = {
  --       DressingInput = false,
  --       TelescopePrompt = false,
  --       noice = false, -- sometimes triggered in error-buffers
  --
  --       -- extra safeguard: `pass` passwords editing filetype is plaintext,
  --       -- also this is the filetype of critical files
  --       text = false,
  --     },
  --   },
  --   config = function(_, opts)
  --     require("neocodeium").setup(opts)
  --
  --     -- disable while recording
  --     vim.api.nvim_create_autocmd("RecordingEnter", { command = "NeoCodeium disable" })
  --     vim.api.nvim_create_autocmd("RecordingLeave", { command = "NeoCodeium enable" })
  --   end,
  --   keys = {
  --     {
  --       "<C-o>",
  --       function()
  --         require("neocodeium").accept()
  --       end,
  --       mode = "i",
  --       desc = "󰚩 Accept full suggestion",
  --     },
  --     {
  --       "<C-y>",
  --       function()
  --         require("neocodeium").accept_line()
  --       end,
  --       mode = "i",
  --       desc = "󰚩 Accept line",
  --     },
  --     -- {
  --     --   "<C-]>",
  --     --   function()
  --     --     require("neocodeium").cycle(1)
  --     --   end,
  --     --   mode = "i",
  --     --   desc = "󰚩 Next suggestion",
  --     -- },
  --     -- {
  --     --   "<C-[>",
  --     --   function()
  --     --     require("neocodeium").cycle(-1)
  --     --   end,
  --     --   mode = "i",
  --     --   desc = "󰚩 Previous suggestion",
  --     -- },
  --     {
  --       "<leader>ua",
  --       function()
  --         vim.cmd.NeoCodeium("toggle")
  --       end,
  --       desc = "󰚩 NeoCodeium Suggestions",
  --     },
  --   },
  -- },
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   event = "VeryLazy",
  --   opts = function(_, opts)
  --     table.insert(opts.sections.lualine_x, 2, function()
  --       -- number meanings: https://github.com/monkoose/neocodeium?tab=readme-ov-file#-statusline
  --       if vim.bo.buftype ~= "" then
  --         return ""
  --       end
  --       local status, server = require("neocodeium").get_status()
  --       if status == 0 and server == 0 then
  --         return ""
  --       end -- working correctly = no component
  --       if server == 1 then
  --         return "󱙺 connecting…"
  --       end
  --       if status == 1 then
  --         return "󱚧 global"
  --       end
  --       if server == 2 then
  --         return "󱚧 server"
  --       end
  --       if status < 5 then
  --         return "󱚧 buffer"
  --       end
  --       return "󱚟 Error"
  --     end)
  --   end,
  -- },
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
}
