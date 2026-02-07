local workspace = vim.fn.expand("$NEXUS_REPO")

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "nexus actions",
  pattern = workspace .. "**",
  callback = function()
    require("modules.translations").setup()
    require("modules.imports").add_snippets()
  end,
  once = true,
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
    "nvim-treesitter/nvim-treesitter",
    config = function()
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
    end,
  },
}
