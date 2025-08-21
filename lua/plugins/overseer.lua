return {
  "stevearc/overseer.nvim",
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
      default = {
        { "open_output", direction = "dock", on_complete = "failure", on_start = "never", focus = false },
        { "display_duration", detail_level = 1 },
        "on_output_summarize",
        "on_exit_set_status",
        "on_complete_notify",
        "on_complete_dispose",
        "unique",
      },
    },
  },

  keys = {
    { "<leader>tt", "<cmd>OverseerToggle<cr>", desc = "Tasks Open" },
    { "<leader>tr", "<cmd>OverseerRun<cr>", desc = "Run task" },

    { "<leader>tml", function() require("overseer").run_template({ name = "make lint" }) end, desc = "Make Lint" },
    { "<leader>tmt", function() require("overseer").run_template({ name = "make test" }) end, desc = "Make Test" },
    {
      "<leader>tmg",
      function() require("overseer").run_template({ name = "make generate-models" }) end,
      desc = "Make Generate Models",
    },
    {
      "<leader>tms",
      function() require("overseer").run_template({ name = "make skaffold-dev" }) end,
      desc = "Make Skaffold Dev",
    },
    { "<leader>ta", function() require("overseer").run_template({ name = "make test" }) end, desc = "Test All" },
    { "<leader>tl", function() require("overseer").run_template({ name = "test-line" }) end, desc = "Test line" },
    { "<leader>tf", function() require("overseer").run_template({ name = "test-file" }) end, desc = "Test file" },
    {
      "<leader>tp",
      function()
        local overseer = require("overseer")
        local task_list = overseer.list_tasks({ recent_first = true })

        -- Find most recent test task
        for _, task in ipairs(task_list) do
          if task.name and task.name:match("^test%-") then
            -- Re-run the same task by restarting it
            task:restart()
            vim.notify("Re-running: " .. task.name, vim.log.levels.INFO)
            return
          end
        end

        vim.notify("No previous test found", vim.log.levels.WARN)
      end,
      desc = "Test previous (repeat last test)",
    },
  },

  config = function(_, opts)
    local overseer = require("overseer")
    overseer.setup(opts)

    -- Function to get the project root
    local function get_project_root()
      return vim.fs.root(vim.api.nvim_get_current_buf(), { "service.yaml", ".git" }) or vim.fn.getcwd()
    end

    -- Treesitter-based test function detection
    local function find_test_function_ts()
      local ts = vim.treesitter
      local bufnr = vim.api.nvim_get_current_buf()
      local filetype = vim.bo[bufnr].filetype

      if filetype ~= "go" then return nil end

      local parser = ts.get_parser(bufnr)
      if not parser then return nil end

      local tree = parser:parse()[1]
      if not tree then return nil end

      local root = tree:root()
      local cursor = vim.api.nvim_win_get_cursor(0)
      local row, col = cursor[1] - 1, cursor[2]

      -- Get node at cursor position
      local node = root:named_descendant_for_range(row, col, row, col)

      local main_func = nil
      local subtest = nil

      -- Walk up the tree to find test function and potential subtest
      while node do
        local node_type = node:type()

        -- Check for t.Run call (subtest)
        if not subtest and node_type == "call_expression" then
          local function_node = node:field("function")[1]
          if function_node and function_node:type() == "selector_expression" then
            local field_node = function_node:field("field")[1]
            if field_node and ts.get_node_text(field_node, bufnr) == "Run" then
              -- Get the test name from the first argument
              local args = node:field("arguments")[1]
              if args and args:type() == "argument_list" then
                local first_arg = args:child(1) -- Skip opening paren
                if
                  first_arg
                  and (first_arg:type() == "interpreted_string_literal" or first_arg:type() == "raw_string_literal")
                then
                  local test_name = ts.get_node_text(first_arg, bufnr)
                  -- Remove quotes
                  subtest = test_name:gsub("^['\"`](.+)['\"`]$", "%1")
                end
              end
            end
          end
        end

        -- Check for main test function
        if not main_func and node_type == "function_declaration" then
          local name_node = node:field("name")[1]
          if name_node then
            local func_name = ts.get_node_text(name_node, bufnr)
            if func_name and func_name:match("^Test") then main_func = func_name end
          end
        end

        node = node:parent()
      end

      -- Return combined main function and subtest if both found
      if main_func and subtest then
        return main_func .. "/" .. subtest
      elseif main_func then
        return main_func
      end

      return nil
    end

    -- Test configuration for different filetypes
    local test_configs = {
      go = {
        test_line_cmd = function(file, func_name)
          -- Handle subtest patterns (e.g., "Test_Integration/testBNL005Operation")
          local cmd = { "go", "test", "-tags=manual_test", "-count=1", "-v", "-run" }

          if func_name:match("/") then
            -- Subtest pattern: convert "Test_Integration/testBNL005Operation" to "^Test_Integration$/^testBNL005Operation$"
            local main_func, subtest = func_name:match("^([^/]+)/(.+)$")
            table.insert(cmd, "^" .. main_func .. "$/^" .. subtest .. "$")
          else
            -- Main test function only
            table.insert(cmd, "^" .. func_name .. "$")
          end

          table.insert(cmd, vim.fn.fnamemodify(file, ":h"))
          return cmd
        end,
        test_file_cmd = function(file)
          return { "go", "test", "-tags=manual_test", "-count=1", "-v", vim.fn.fnamemodify(file, ":h") }
        end,
        get_test_function = find_test_function_ts,
      },
      -- TODO: Add other languages (typescript, javascript, python, rust, etc.)
    }

    -- Helper function to get current filetype config
    local function get_test_config()
      local ft = vim.bo.filetype
      return test_configs[ft]
    end

    overseer.register_template({
      name = "test-line",
      builder = function()
        local config = get_test_config()
        if not config then
          vim.notify("Test line not supported for filetype: " .. vim.bo.filetype, vim.log.levels.WARN)
          return nil
        end

        local file = vim.fn.expand("%:p")
        local func_name = config.get_test_function()

        if not func_name then
          vim.notify("No test function found at current line", vim.log.levels.WARN)
          return nil
        end

        return {
          name = "test-line: " .. func_name,
          cmd = config.test_line_cmd(file, func_name),
          cwd = get_project_root(),
        }
      end,
    })

    overseer.register_template({
      name = "test-file",
      builder = function()
        local config = get_test_config()
        if not config then
          vim.notify("Test file not supported for filetype: " .. vim.bo.filetype, vim.log.levels.WARN)
          return nil
        end

        local file = vim.fn.expand("%:p")

        return {
          name = "test-file: " .. vim.fn.expand("%:t"),
          cmd = config.test_file_cmd(file),
          cwd = get_project_root(),
        }
      end,
    })

    overseer.register_template({
      name = "make skaffold-dev",
      builder = function()
        return {
          cmd = { "make", "skaffold-dev-remotedev", "ALIAS=" .. (os.getenv("USER") or "user") },
          cwd = get_project_root(),
          components = {
            "default",
            {
              "restart_on_save",
              paths = { get_project_root() },
              delay = 1000,
              interrupt = true,
            },
            {
              "on_output_parse",
              parser = {
                { "extract", "Press any key to rebuild/redeploy", "_" },
                {
                  "always",
                  {
                    "dispatch",
                    function()
                      vim.schedule(function()
                        local project_name = vim.fn.fnamemodify(get_project_root(), ":t")
                        vim.notify("🚀 " .. project_name .. " ready", vim.log.levels.INFO)
                      end)
                    end,
                  },
                },
              },
            },
          },
        }
      end,
    })

    overseer.register_template({
      name = "make lint",
      builder = function()
        return {
          cmd = { "make", "lint" },
          cwd = get_project_root(),
        }
      end,
    })

    overseer.register_template({
      name = "make test",
      builder = function()
        return {
          name = "make test",
          cmd = { "make", "test" },
          cwd = get_project_root(),
        }
      end,
    })
  end,
}
