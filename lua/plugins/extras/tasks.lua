local function parent_dir()
  return vim.fs.dirname(vim.api.nvim_buf_get_name(0))
end

local function golang_adapter()
  local opts = {
    runner = "gotestsum",
    go_test_args = { "-v", "-count=1", "-tags=manual_test" },
    -- standard-verbose streams the full `go test -v` output, including t.Logf and stdout of passing tests.
    -- Per session override for the compact output: `:let g:gotestsum_format = "testname"`.
    gotestsum_args = function()
      return { "--format=" .. (vim.g.gotestsum_format or "standard-verbose") }
    end,
    warn_test_name_dupes = false,
  }
  local adapter = require("neotest-golang")(opts)

  -- root is better to be cwd (changed wit autocmd), good for monorepos
  adapter.root = function()
    return parent_dir()
  end

  return adapter
end

local function vitest_adapter()
  local adapter = require("neotest-vitest")
  adapter.root = function()
    return parent_dir()
  end
  return adapter
end

return {
  {
    "stevearc/overseer.nvim",
    opts = {
      dap = false,
      task_list = {
        min_height = { 15, 0.3 },
        keymaps = {
          ["<C-j>"] = false,
          ["<C-k>"] = false,
          ["k"] = "keymap.prev_task",
          ["j"] = "keymap.next_task",
        },
      },
      form = {
        win_opts = {
          winblend = 0,
        },
      },
      confirm = {
        win_opts = {
          winblend = 0,
        },
      },
      task_win = {
        win_opts = {
          winblend = 0,
        },
      },
      component_aliases = {
        default = {
          "on_exit_set_status",
          { "on_complete_notify", system = "unfocused" },
          { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },

          { "open_output", direction = "dock", on_complete = "never", on_start = "never", focus = false },
          "unique",
          { "on_output_quickfix", close = true },
        },
        -- Own list instead of extending "default", because open_output may only be declared once per task.
        default_neotest = {
          "on_exit_set_status",
          { "on_complete_notify", system = "unfocused", on_change = true },
          { "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
          { "open_output", direction = "dock", on_start = "always", focus = false },
          "unique",
          { "on_output_quickfix", close = true },
        },
      },
    },
    keys = {
      { "<leader>tt", "<cmd>OverseerToggle<cr>", desc = "Tasks Open" },
      { "<leader>tr", "<cmd>OverseerRun<cr>", desc = "Run task" },
      { "<leader>ta", "<cmd>OverseerTaskAction<cr>", desc = "OverseerTaskAction" },
      { "<leader>tq", "<cmd>OverseerShell<cr>", desc = "Overseer Quick Shell" },
    },

    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",
      -- adapters
      "fredrikaverpil/neotest-golang",
      "marilari88/neotest-vitest",
    },
    config = function()
      require("neotest").setup({
        consumers = {
          overseer = require("neotest.consumers.overseer"),
        },
        adapters = {
          golang_adapter(),
          vitest_adapter(),
        },
        icons = {
          expanded = "",
          child_prefix = "",
          child_indent = "",
          final_child_prefix = "",
          non_collapsible = "",
          collapsed = "",

          passed = "",
          running = "󰑧",
          failed = "",
          unknown = "",
        },
      })
    end,
    keys = {
      {
        "<leader>tf",
        function()
          require("neotest").output_panel.clear()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "[t]est run [f]ile",
      },
      {
        "<leader>tA",
        function()
          require("neotest").output_panel.clear()
          require("neotest").run.run(vim.uv.cwd())
        end,
        desc = "[t]est [A]ll files",
      },
      {
        "<leader>tn",
        function()
          require("neotest").output_panel.clear()
          require("neotest").run.run()
        end,
        desc = "[t]est [n]earest",
      },
      {
        "<leader>tl",
        function()
          require("neotest").output_panel.clear()
          require("neotest").run.run_last()
        end,
        desc = "[t]est [l]ast",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "[t]est [s]ummary",
      },
      {
        "<leader>tO",
        function()
          require("neotest").output.open({ enter = true, auto_close = true })
        end,
        desc = "[t]est [O]utput",
      },
      {
        "<leader>to",
        function()
          local neotest = require("neotest")
          local op = neotest.output_panel
          if vim.api.nvim_get_current_buf() == op.buffer() then
            return op.close()
          end
          op.open()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == op.buffer() then
              vim.api.nvim_set_current_win(win)
              vim.cmd("normal! gg")
              return
            end
          end
        end,
        desc = "[t]est [o]utput panel",
      },
    },
  },
}
