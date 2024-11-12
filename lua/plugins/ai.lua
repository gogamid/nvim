local tabnine_enterprise_host = "https://tabnine.stackit.run"
return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {
      window = {
        layout = "float", -- 'vertical', 'horizontal', 'float', 'replace'
        width = 0.65,
        height = 0.9,
      },
    },
  },

  {
    "codota/tabnine-nvim",
    enabled = false,
    build = "./dl_binaries.sh " .. tabnine_enterprise_host .. "/update",
    keys = {
      { "<leader>ua", "<cmd>TabnineToggle<CR>", desc = "Toggle Tabnine" },
    },
    config = function()
      require("tabnine").setup({
        disable_auto_comment = true,
        accept_keymap = "<C-o>",
        dismiss_keymap = "<C-c>",
        debounce_ms = 800,
        suggestion_color = { gui = "#808080", cterm = 244 },
        codelens_color = { gui = "#808080", cterm = 244 },
        codelens_enabled = false,
        exclude_filetypes = { "TelescopePrompt", "NvimTree" },
        log_file_path = nil, -- absolute path to Tabnine log file
        tabnine_enterprise_host = tabnine_enterprise_host,
        ignore_certificate_errors = false,
      })
    end,
  },
}
