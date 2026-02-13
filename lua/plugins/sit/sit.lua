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
    vim.notify("Installed custom go parser")

    require("nvim-treesitter.parsers").gupta = {
      filetype = "gupta",
      install_info = {
        path = "~/personal/tree-sitter-gupta",
        generate = false,
        queries = "queries",
      },
    }
    vim.notify("Installed custom gupta parser")
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

return {
  { "nvim-treesitter/nvim-treesitter" },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          git_log = git_options,
          git_log_file = git_options,
          git_log_line = git_options,
        },
      },
    },
    keys = {
      {
        "<leader>fs",
        function()
          Snacks.picker.files({ dirs = { service_dir() } })
        end,
        desc = "Service files",
      },
      {
        "<leader>fd",
        function()
          Snacks.picker.files({ dirs = { domain_dir() } })
        end,
        desc = "Domain files",
      },
      {
        "<leader>ss",
        function()
          Snacks.picker.grep({ dirs = { service_dir() } })
        end,
        desc = "Service grep",
      },
      {
        "<leader>sd",
        function()
          Snacks.picker.grep({ dirs = { domain_dir() } })
        end,
        desc = "Domain grep",
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)
      Snacks.toggle
        .new({
          id = "goarch",
          name = "GOARCH and CGO_ENABLED",
          get = function()
            return vim.env.GOARCH
          end,
          set = function(state)
            if state then
              vim.env.ORACLE_HOME = vim.env.HOMEBREW_PREFIX
              vim.env.GOARCH = "amd64"
              vim.env.CGO_ENABLED = "1"
            else
              vim.env.ORACLE_HOME = vim.env.HOMEBREW_PREFIX
              vim.env.GOARCH = nil
              vim.env.CGO_ENABLED = nil
            end
          end,
        })
        :map("<leader>ua")
    end,
  },
  {
    "stevearc/overseer.nvim",
    config = function()
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
    end,
  },
}
