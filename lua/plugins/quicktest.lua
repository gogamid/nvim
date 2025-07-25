-- "popup" or "split"
local mode = "split"
return {
  "quolpr/quicktest.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
--stylua: ignore
  keys = {
    { "<leader>tl", ":QuicktestRunLine<CR>", desc = "[T]est Run [L]line" },
    { "<leader>tf", ":QuicktestRunFile<CR>", desc = "[T]est Run [F]ile" },
    { "<leader>td", ":QuicktestRunDir<CR>", desc = "[T]est Run [D]ir" },
    { "<leader>ta", ":QuicktestRunAll<CR>", desc = "[T]est Run [A]ll" },
    { "<leader>tp", function() require("quicktest").run_previous() end, desc = "[T]est Run [P]revious" },
    { "<leader>tt", function() require("quicktest").toggle_win(mode) end, desc = "[T]est [T]oggle Window" },
    { "<leader>ts", function()  require("quicktest").cancel_current_run() end, desc = "[T]est [C]ancel Current Run" },
  },
  config = function(_, opts)
    require("quicktest").setup({
      adapters = {
        require("quicktest.adapters.golang")({
          args = function(_, args)
            vim.list_extend(args, { "-tags=manual_test", "-count=1" })
            return args
          end,
        }),
        require("quicktest.adapters.vitest")({}),
      },
      -- split or popup mode, when argument not specified
      default_win_mode = mode,
      use_experimental_colorizer = false,
      use_baleia = false,

      popup_options = {
        relative = "editor",
        position = {
          row = "50%",
          col = "50%",
        },
        size = {
          width = "95%",
          height = "80%",
        },
        zindex = 100,
      },
      use_builtin_colorizer = false,
    })
  end,
}
