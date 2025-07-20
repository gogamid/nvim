return {
  "quolpr/quicktest.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>tl", ":QuicktestRunLine<CR>", desc = "[T]est Run [L]line" },
    { "<leader>tf", ":QuicktestRunFile<CR>", desc = "[T]est Run [F]ile" },
    { "<leader>td", ":QuicktestRunDir<CR>", desc = "[T]est Run [D]ir" },
    { "<leader>ta", ":QuicktestRunAll<CR>", desc = "[T]est Run [A]ll" },
    {
      "<leader>tp",
      function()
        require("quicktest").run_previous()
      end,
      desc = "[T]est Run [P]revious",
    },
    {
      "<leader>tt",
      function()
        require("quicktest").toggle_win("popup")
      end,
      desc = "[T]est [T]oggle Window",
    },
    {
      "<leader>ts",
      function()
        local qt = require("quicktest")
        qt.cancel_current_run()
      end,
      desc = "[T]est [C]ancel Current Run",
    },
  },
  config = function(_, opts)
    require("quicktest").setup({
      -- Choose your adapter, here all supported adapters are listed
      adapters = {
        require("quicktest.adapters.golang")({
          args = function(bufnt, args)
            vim.list_extend(args, { "-count=1" })
            return args
          end,
          additional_args = function(_)
            return { "-tags=manual_test" }
          end,
        }),
        require("quicktest.adapters.vitest")({}),
      },
      -- split or popup mode, when argument not specified
      default_win_mode = "popup",
      use_experimental_colorizer = true,
      use_baleia = false,

      popup_options = {
        enter = true,
        bufnr = popup_buf,
        focusable = true,
        border = {
          style = "rounded",
        },
        relative = "editor",
        position = {
          row = "50%",
          col = "50%",
        },
        size = {
          width = "95%",
          height = "80%",
        },
        zindex = 100, -- Ensure the popup is on top of all panes
      },
      use_builtin_colorizer = true,
    })
  end,
}
