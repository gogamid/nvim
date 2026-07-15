vim.api.nvim_create_autocmd("BufEnter", {
  pattern = vim.fn.expand("$NEXUS_REPO") .. "**",
  callback = function()
    require("modules.imports").add_snippets()
    require("modules.translations").setup()
  end,
  once = true,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "TSUpdate",
  callback = function()
    require("nvim-treesitter.parsers").go = {
      install_info = {
        path = "~/personal/tree-sitter-go",
      },
    }
    require("nvim-treesitter.parsers").gupta = {
      filetype = "gupta",
      install_info = {
        path = "~/personal/tree-sitter-gupta",
        generate = false,
        queries = "queries",
      },
    }
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gupta", "go" },
  callback = function()
    vim.treesitter.start()
  end,
})

local function service_dir()
  local dir = vim.fs.root(0, { "service.yaml" })
  if dir == nil then
    vim.notify("No service.yaml file found", vim.log.levels.WARN)
  end
  return dir
end

local function domain_dir()
  local dir = vim.fs.root(0, { "sonar-project.properties" })
  if dir == nil then
    vim.notify("No sonar-project.properties file found", vim.log.levels.WARN)
  end
  return dir
end

--[[
local git_options = {
  actions = {
    ["copy_pr_url"] = function(picker)
      local currentMsg = picker:current().msg
      if currentMsg then
        local pr_number = string.match(currentMsg, "Merged PR (%d+):")
        if pr_number then
          local url = os.getenv("AZURE_PR_URL") .. pr_number
          vim.fn.setreg("+", url)
          vim.notify(string.format("PR URL copied: %s", url))
        else
          vim.notify("PR number not found in message.", vim.log.levels.ERROR)
        end
      end
    end,
    ["open_pr"] = function(picker)
      local currentMsg = picker:current().msg
      if currentMsg then
        local pr_number = string.match(currentMsg, "Merged PR (%d+):")
        if pr_number then
          local url = os.getenv("AZURE_PR_URL") .. pr_number
          vim.fn.system({ "open", url })
        else
          vim.notify("PR number not found in message.", vim.log.levels.ERROR)
        end
      end
    end,
  },
  win = {
    input = {
      keys = {
        ["<C-o>y"] = { "copy_pr_url", desc = "Copy PR URL", mode = { "n", "i" } },
        ["<C-o>b"] = { "open_pr", desc = "Open PR", mode = { "n", "i" } },
      },
    },
  },
}
--]]

return {
  { "nvim-treesitter/nvim-treesitter" },
  {
    "folke/snacks.nvim",
    -- picker sources and keys moved to fff.lua
    config = function(_, opts)
      require("snacks").setup(opts)
    end,
  },
  {
    "dmtrKovalenko/fff.nvim",
    keys = {
      {
        "<leader>fs",
        function()
          local dir = service_dir()
          if dir then
            require("fff").find_files_in_dir(dir)
          end
        end,
        desc = "Service files",
      },
      {
        "<leader>fd",
        function()
          local dir = domain_dir()
          if dir then
            require("fff").find_files_in_dir(dir)
          end
        end,
        desc = "Domain files",
      },
      {
        "<leader>ss",
        function()
          local dir = service_dir()
          if dir then
            require("fff").live_grep({ cwd = dir })
          end
        end,
        desc = "Service grep",
      },
      {
        "<leader>sd",
        function()
          local dir = domain_dir()
          if dir then
            require("fff").live_grep({ cwd = dir })
          end
        end,
        desc = "Domain grep",
      },
    },
  },
  {
    "stevearc/overseer.nvim",
    keys = {
      {
        "<leader>ml",
        function()
          local dir = service_dir()
          if dir == nil then
            return
          end
          local service = vim.fs.basename(service_dir())
          local name = string.format("lint[%s]", service)
          local task = require("overseer").new_task({
            cmd = { "sh", "-lc", "make fix && make lint" },
            name = name,
            cwd = dir,
          })
          task:start()
          vim.notify(string.format("Running make fix and lint for %s", service))
        end,
        desc = "Make fix and lint",
      },
      {
        "<leader>mt",
        function()
          require("overseer").run_task({ name = "make test" })
          vim.notify("Running make test")
        end,
        desc = "Make test",
      },
      {
        "<leader>mc",
        function()
          require("overseer").run_task({ name = "make check" })
          vim.notify("Running make check")
        end,
        desc = "Make check",
      },
      {
        "<leader>mg",
        function()
          require("overseer").run_task({ name = "generate all models" })
          vim.notify("Running make generate")
        end,
        desc = "Make generate models",
      },
      {
        "<leader>ms",
        function()
          require("overseer").run_task({ name = "skaffold dev" })
          vim.notify("Running skaffold dev")
        end,
        desc = "skaffold dev",
      },
      {
        "<leader>mr",
        function()
          local country_code = vim.fn.input("Country code: ")
          if country_code == "" then
            vim.notify("Country code required", vim.log.levels.ERROR)
            return
          end
          local dir = service_dir()
          if dir == nil then
            return
          end
          local task = require("overseer").new_task({
            cmd = { "make", "-C", dir, "run" },
            env = { WAWI_COUNTRY = country_code, WAWI_ENV = "dev" },
            name = string.format("%s[run]", country_code),
          })
          task:start()
          vim.notify(string.format("Running make run for %s", country_code))
        end,
        desc = "Make run with country code",
      },
    },
    config = function(_, opts)
      require("overseer").setup(opts)

      local overseer = require("overseer")
      overseer.register_template({
        name = "skaffold dev",
        condition = {
          dir = vim.fn.expand("$NEXUS_REPO"),
        },
        builder = function()
          local service = vim.fs.basename(service_dir())
          if service == nil then
            return {}
          end

          return {
            name = service .. "[dev]",
            cmd = {
              "make",
              "-C",
              service_dir(),
              "skaffold-dev-remotedev",
              "ALIAS=" .. (os.getenv("USER") or "user"),
            },
          }
        end,
      })

      overseer.register_template({
        name = "auth skaffold dev",
        condition = {
          dir = vim.fn.expand("$NEXUS_REPO"),
        },
        builder = function()
          return {
            name = "auth[dev]",
            cmd = {
              "make",
              "-C",
              vim.env.NEXUS_REPO .. "/domains/wam/services/auth",
              "skaffold-dev-remotedev",
              "ALIAS=" .. vim.env.USER,
            },
          }
        end,
      })

      overseer.register_template({
        name = "generate all models",
        condition = {
          dir = vim.fn.expand("$NEXUS_REPO"),
        },
        builder = function()
          return {
            name = "gen",
            cmd = {
              "make",
              "-C",
              vim.env.NEXUS_REPO,
              "generate-models",
            },
          }
        end,
      })

      overseer.register_template({
        name = "port forward 50051",
        condition = {
          dir = vim.fn.expand("$NEXUS_REPO"),
        },
        builder = function()
          local service = vim.fs.basename(service_dir())
          local domain = vim.fs.basename(domain_dir())
          if service == nil or domain == nil then
            vim.notify("No service or domain found", vim.log.levels.WARN)
            return {}
          end

          return {
            name = service .. "[pf]",
            cmd = {
              "kubectl",
              "-n",
              domain,
              "port-forward",
              "service/" .. service,
              "50051",
            },
          }
        end,
      })
    end,
  },
}
