return {
  {
    "stevearc/overseer.nvim",
    version = "1.6.0", -- before major refactoring
    opts = {
      dap = false,
      task_list = {
        min_height = { 15, 0.3 },
        bindings = {
          ["<C-h>"] = false,
          ["<C-j>"] = false,
          ["<C-k>"] = false,
          ["<C-l>"] = false,
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
        default_neotest = {
          "on_output_summarize",
          "on_exit_set_status",
          "on_complete_notify",
          "on_complete_dispose",
        },
        default = {
          { "open_output", direction = "dock", on_complete = "failure", on_start = "never", focus = false },
          { "display_duration", detail_level = 1 },
          "on_output_summarize",
          "on_exit_set_status",
          "on_complete_notify",
          "unique",
        },
      },
    },
    keys = {
      { "<leader>tt", "<cmd>OverseerToggle<cr>", desc = "Tasks Open" },
      { "<leader>tr", "<cmd>OverseerRun<cr>", desc = "Run task" },
      {
        "<leader>tmg",
        function()
          require("overseer").run_template({ name = "make generate-models" })
        end,
        desc = "Make Generate Models",
      },
      {
        "<leader>tms",
        function()
          require("overseer").run_template({ name = "make skaffold-dev" })
        end,
        desc = "Make Skaffold Dev",
      },
    },

    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        desc = "Toggle Overseer with q",
        pattern = "OverseerList",
        callback = function(event)
          vim.bo[event.buf].buflisted = false
          vim.schedule(function()
            vim.keymap.set("n", "q", function()
              vim.cmd("OverseerToggle")
            end, {
              buffer = event.buf,
              silent = true,
              desc = "Toggle Overseer",
            })
          end)
        end,
      })

      -- Function to get the project root
      local function get_project_root()
        return vim.fs.root(0, { "service.yaml", ".git" }) or vim.fn.getcwd()
      end

      overseer.register_template({
        name = "skaffold dev",
        condition = {
          dir = os.getenv("NEXUS_REPO"),
        },
        builder = function()
          local cwd = get_project_root()
          return {
            cmd = { "make", "skaffold-dev-remotedev", "ALIAS=" .. (os.getenv("USER") or "user") },
            cwd = cwd,
            name = "sk " .. vim.fn.fnamemodify(cwd, ":t"),
            components = {
              { "unique", replace = false },
              {
                "restart_on_save",
                paths = { cwd .. "/main/**" },
                delay = 10,
                interrupt = true,
              },
              "on_output_summarize",
              "on_exit_set_status",
              "on_complete_notify",
              "on_complete_dispose",
            },
          }
        end,
      })

      overseer.register_template({
        name = "auth skaffold dev",
        condition = {
          dir = os.getenv("NEXUS_REPO"),
        },
        builder = function()
          return {
            name = "auth skaffold dev",
            cmd = {
              "make",
              "-C",
              (os.getenv("NEXUS_REPO") or "") .. "/domains/wam/services/auth",
              "skaffold-dev-remotedev",
              "ALIAS=" .. (os.getenv("USER") or "user"),
            },
          }
        end,
      })

      overseer.register_template({
        name = "",
        condition = {
          dir = os.getenv("NEXUS_REPO"),
        },
        builder = function()
          local cwd = get_project_root()
          return {
            name = "make lint " .. vim.fn.fnamemodify(cwd, ":t"),
            cmd = { "make", "lint" },
            cwd = cwd,
          }
        end,
      })

      overseer.register_template({
        name = "make test",
        condition = {
          dir = os.getenv("NEXUS_REPO"),
        },
        builder = function()
          local cwd = get_project_root()
          return {
            name = "make test " .. vim.fn.fnamemodify(cwd, ":t"),
            cmd = { "make", "test" },
            cwd = cwd,
          }
        end,
      })

      overseer.register_template({
        name = "colima start",
        builder = function()
          return {
            cmd = { "colima", "start" },
          }
        end,
      })

      overseer.register_template({
        name = "activate pim roles",
        builder = function()
          return {
            cmd = { os.getenv("HOME") .. "/work/nexus-tools/azurelogin.sh", "all" },
          }
        end,
      })
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",

      { "fredrikaverpil/neotest-golang", version = "2.4.0" },
      "marilari88/neotest-vitest",
    },
    config = function()
      require("neotest").setup({
        consumers = {
          overseer = require("neotest.consumers.overseer"),
        },
        adapters = {
          require("neotest-golang")({
            -- "-timeout=60s",
            go_test_args = { "-v", "-count=1", "-tags=manual_test" },
          }),
          require("neotest-vitest"),
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
