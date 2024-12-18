return {
  "quolpr/quicktest.nvim",
  config = function()
    local qt = require("quicktest")

    qt.setup({
      -- Choose your adapter, here all supported adapters are listed
      adapters = {
        require("quicktest.adapters.golang")({}),
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
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    {
      "<leader>tl",
      function()
        local qt = require("quicktest")
        -- current_win_mode return currently opened panel, split or popup
        qt.run_line()
        -- You can force open split or popup like this:
        -- qt.run_line('split')
        -- qt.run_line('popup')
      end,
      desc = "[T]est Run [L]line",
    },
    {
      "<leader>tf",
      function()
        local qt = require("quicktest")

        qt.run_file()
      end,
      desc = "[T]est Run [F]ile",
    },
    {
      "<leader>td",
      function()
        local qt = require("quicktest")

        qt.run_dir()
      end,
      desc = "[T]est Run [D]ir",
    },
    {
      "<leader>ta",
      function()
        local qt = require("quicktest")

        qt.run_all()
      end,
      desc = "[T]est Run [A]ll",
    },
    {
      "<leader>tp",
      function()
        local qt = require("quicktest")

        qt.run_previous()
      end,
      desc = "[T]est Run [P]revious",
    },
    {
      "<leader>tt",
      function()
        local qt = require("quicktest")

        qt.toggle_win("popup")
      end,
      desc = "[T]est [T]oggle Window",
    },
    {
      "<leader>tc",
      function()
        local qt = require("quicktest")

        qt.cancel_current_run()
      end,
      desc = "[T]est [C]ancel Current Run",
    },
  },
}
