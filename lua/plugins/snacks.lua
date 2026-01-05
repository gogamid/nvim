local git_options = {
  actions = {
    ["diffview"] = function(picker)
      local currentCommit = picker:current().commit
      if currentCommit then
        local args = { currentCommit .. "^" .. "!" }
        require("diffview").open(args)
      end
    end,
    ["codediff"] = function(picker)
      local curr = picker:current().commit
      if not curr then
        err("No commit selected", "codediff")
        return
      end
      local prev = vim.trim(vim.fn.system("git rev-parse --short " .. curr .. "^"))
      prev = prev:match("[a-f0-9]+")
      vim.cmd(string.format("CodeDiff %s %s", prev, curr))
    end,
    ["copy_pr_url"] = function(picker)
      local currentMsg = picker:current().msg
      if currentMsg then
        local pr_number = string.match(currentMsg, "Merged PR (%d+):")
        if pr_number then
          local url = os.getenv("AZURE_PR_URL") .. pr_number
          vim.fn.setreg("+", url)
          info(string.format("PR URL copied: %s", url))
        else
          err("PR number not found in message.")
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
          err("PR number not found in message.")
        end
      end
    end,
  },
  win = {
    input = {
      keys = {
        ["<CR>"] = { "diffview", desc = "Diffview this commit", mode = { "n", "i" } },
        ["<C-y>"] = { "copy_pr_url", desc = "Copy PR URL", mode = { "n", "i" } },
        ["<C-o>"] = { "open_pr", desc = "Open PR", mode = { "n", "i" } },
      },
    },
  },
}

local picker_options = {
  ---@class snacks.picker.matcher.Config
  matcher = {
    fuzzy = true, -- use fuzzy matching
    smartcase = true, -- use smartcase
    ignorecase = true, -- use ignorecase
    sort_empty = false, -- sort results when the search string is empty
    filename_bonus = true, -- give bonus for matching file names (last part of the path)
    file_pos = true, -- support patterns like `file:line:col` and `file:line`
    -- the bonusses below, possibly require string concatenation and path normalization,
    -- so this can have a performance impact for large lists and increase memory usage
    cwd_bonus = false, -- give bonus for matching files in the cwd
    frecency = true, -- frecency bonus
    history_bonus = false, -- give more weight to chronological order
  },
  sources = {
    git_log = git_options,
    git_log_file = git_options,
    git_log_line = git_options,
  },
  win = {
    input = {
      keys = {
        -- disable unnecessary keys since we want the help menu to be usefult
        ["/"] = false,
        ["<C-Down>"] = false,
        ["<C-Up>"] = false,
        -- ["<C-c>"] = false,
        -- ["<C-w>"] = false,
        -- ["<CR>"] = false,
        ["<Down>"] = false,
        -- ["<Esc>"] = false,
        ["<S-CR>"] = false,
        ["<S-Tab>"] = false,
        ["<Tab>"] = false,
        ["<Up>"] = false,
        ["<a-d>"] = false,
        ["<a-f>"] = false,
        ["<a-h>"] = false,
        ["<a-i>"] = false,
        ["<a-r>"] = false,
        ["<a-m>"] = false,
        ["<a-p>"] = false,
        ["<a-w>"] = false,
        -- ["<c-a>"] = false,
        -- ["<c-b>"] = false,
        -- ["<c-d>"] = false,
        -- ["<c-f>"] = false,
        -- ["<c-g>"] = false,
        -- ["<c-j>"] = false,
        -- ["<c-k>"] = false,
        -- ["<c-n>"] = false,
        -- ["<c-p>"] = false,
        -- ["<c-q>"] = false,
        -- ["<c-s>"] = false,
        ["<c-t>"] = false,
        -- ["<c-u>"] = false,
        -- ["<c-v>"] = false,
        ["<c-r>#"] = false,
        ["<c-r>%"] = false,
        ["<c-r><c-a>"] = false,
        ["<c-r><c-f>"] = false,
        ["<c-r><c-l>"] = false,
        ["<c-r><c-p>"] = false,
        ["<c-r><c-w>"] = false,
        ["<c-w>H"] = false,
        ["<c-w>J"] = false,
        ["<c-w>K"] = false,
        ["<c-w>L"] = false,
        -- ["?"] = false,
        ["G"] = false,
        ["gg"] = false,
        ["j"] = false,
        ["k"] = false,
        -- ["q"] = true,

        -- used keys

        ["<C-c>"] = { "cancel", mode = "i" },
        ["<CR>"] = { "confirm", mode = { "n", "i" } },

        ["<c-s>"] = { "edit_split", mode = { "i", "n" } },
        ["<c-v>"] = { "edit_vsplit", mode = { "i", "n" } },

        ["<c-z>"] = { "toggle_maximize", mode = { "n", "i" } },
        ["<c-h>"] = { "toggle_help_input", mode = { "i", "n" } },
        ["<c-e>"] = { "cycle_win", mode = { "i", "n" } },

        ["<c-,>"] = { "toggle_ignored", mode = { "i", "n" } },
        ["<c-.>"] = { "toggle_hidden", mode = { "i", "n" } },
        ["<c-g>"] = { "toggle_live", mode = { "i", "n" } },
        ["<c-r>"] = { "toggle_regex", mode = { "i", "n" } },

        ["<c-k>"] = { "history_back", mode = { "i", "n" } },
        ["<c-j>"] = { "history_forward", mode = { "i", "n" } },

        ["<c-l>"] = { "select_and_next", mode = { "n", "i" } },
        ["<c-a>"] = { "select_all", mode = { "n", "i" } },

        ["<c-w>"] = { "<c-s-w>", mode = { "i" }, expr = true, desc = "delete word" },

        ["<c-n>"] = { "list_down", mode = { "i", "n" } },
        ["<c-p>"] = { "list_up", mode = { "i", "n" } },
        ["<c-u>"] = { "list_scroll_up", mode = { "i", "n" } },
        ["<c-d>"] = { "list_scroll_down", mode = { "i", "n" } },
        ["<c-b>"] = { "preview_scroll_up", mode = { "i", "n" } },
        ["<c-f>"] = { "preview_scroll_down", mode = { "i", "n" } },

        -- ["<c-q>"] = quickfix

        ["<c-i>"] = { "inspect", mode = { "n", "i" } },
      },
      b = {
        minipairs_disable = true,
      },
    },
    list = {
      keys = {
        ["<c-e>"] = "cycle_win",
      },
    },
    preview = {
      minimal = false,
      wo = {
        cursorline = false,
        colorcolumn = "",
      },
      keys = {
        ["<c-e>"] = "cycle_win",
      },
    },
  },
  layout = { preset = "custom" },
  layouts = {
    custom = {
      layout = {
        backdrop = false,
        row = 1,
        width = 0.7,
        min_width = 80,
        height = 0.95,
        border = "none",
        box = "vertical",
        { win = "preview", height = 0.6, border = "rounded" },
        {
          box = "vertical",
          border = "rounded",
          title = "{source} {live}",
          title_pos = "center",
          { win = "input", height = 1, border = "bottom" },
          { win = "list", border = "none" },
        },
      },
    },
  },
  formatters = {
    file = {
      filename_first = true,
      truncate = 1000,
    },
  },
}

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    picker = picker_options,
    image = {},
    dashboard = {
      enabled = false,
      preset = {
        keys = {},
        header = require("modules.headers").hello_papi,
      },
      formats = { key = { "" } },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    lazygit = {
      enabled = true,
      win = {
        width = 0.99,
        height = 0.99,
      },
    },
    terminal = { enabled = false },
    bigfile = { enabled = false },
    notifier = {
      enabled = true,
      timeout = 3000,
      margin = { top = 0, right = 1, bottom = 1, left = 0 },
      top_down = false,
    },
    quickfile = { enabled = true },
    statuscolumn = {
      enabled = true, -- automatically enable statuscolumn
      left = { "mark", "sign" }, -- priority of signs on the left (high to low)
      right = { "fold", "git" }, -- priority of signs on the right (high to low)
      folds = {
        open = true, -- show open fold icons
        git_hl = true, -- use Git Signs hl for fold icons
      },
      git = {
        patterns = { "MiniDiffSign" }, -- patterns to match Git signs
      },
      refresh = 50, -- refresh at most every 50ms
    },
    styles = {
      notification = {
        wo = { wrap = true }, -- Wrap notifications
      },
    },
    zen = {
      toggles = { dim = false },
      win = {
        width = 100,
      },
    },
    input = { enabled = true },
    gitbrowse = {
      url_patterns = {
        ["dev%.azure%.com"] = {
          branch = "?version=GB{branch}",
          file = function(fields)
            local line_end = fields.line_end and (fields.line_end + 1) or fields.line_start
            return string.format(
              "?path=/%s&version=GB%s&line=%s&lineEnd=%s&lineStartColumn=1&lineEndColumn=1&lineStyle=plain&_a=contents",
              fields.file or "",
              fields.branch or "",
              fields.line_start or "",
              line_end
            )
          end,
          permalink = function(fields)
            local line_end = fields.line_end and (fields.line_end + 1) or fields.line_start
            return string.format(
              "?path=/%s&version=GC%s&line=%s&lineEnd=%s&lineStartColumn=1&lineEndColumn=1&lineStyle=plain&_a=contents",
              fields.file or "",
              fields.commit or "",
              fields.line_start or "",
              line_end
            )
          end,
          commit = "/commit/{commit}",
        },
      },
    },
    explorer = { enabled = false },
    indent = {
      indent = {
        char = "",
      },
    },
    scope = { enabled = true },
    scroll = { enabled = false },
    -- Auto-show LSP references and quickly navigate between them
    words = { enabled = true },
  },
  keys = {
    -- files
    {
      "<leader>ff",
      function()
        Snacks.picker.files()
      end,
      desc = "Cwd Files",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.git_files({ untracked = true })
      end,
      desc = "Git Files",
    },
    {
      "<leader>fs",
      function()
        Snacks.picker.files({ dirs = { vim.fs.root(vim.api.nvim_get_current_buf(), { "service.yaml", ".git" }) } })
      end,
      desc = "Service Files",
    },
    {
      "<leader>fd",
      function()
        Snacks.picker.files({
          dirs = { vim.fs.root(vim.api.nvim_get_current_buf(), { "sonar-project.properties", ".git" }) },
        })
      end,
      desc = "Domain Files",
    },
    {
      "<leader>fb",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Buffer Files",
    },
    {
      "<leader>,",
      function()
        Snacks.picker.buffers()
      end,
      desc = "Buffer Files",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent()
      end,
      desc = "Recent Files",
    },
    {
      "<leader>fp",
      function()
        Snacks.picker.files({ cwd = require("lazy.core.config").options.root, ft = "lua" })
      end,
      desc = "Plugin Files",
    },
    {
      "<leader>fc",
      function()
        Snacks.picker.files({ dirs = { os.getenv("HOME") .. "/.config" } })
      end,
      desc = "Config Files",
    },

    -- git
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "<leader>gl",
      function()
        Snacks.picker.git_log()
      end,
      desc = "Logs",
    },
    {
      "<leader>gb",
      function()
        Snacks.picker.git_log_line()
      end,
      desc = "Blame Logs",
    },
    {
      "<leader>gf",
      function()
        Snacks.picker.git_log_file()
      end,
      desc = "File Logs",
    },
    {
      "<leader>gs",
      function()
        Snacks.picker.git_status()
      end,
      desc = "Status",
    },
    -- {
    --   "<leader>gd",
    --   function()
    --     Snacks.picker.git_diff()
    --   end,
    --   desc = "Diffs",
    -- },
    {
      "<leader>go",
      function()
        Snacks.gitbrowse()
      end,
      desc = "Open in browser",
      mode = { "n", "v" },
    },
    {
      "<leader>gy",
      function()
        Snacks.gitbrowse({
          open = function(url)
            vim.fn.setreg("+", url)
          end,
          notify = false,
        })
      end,
      desc = "Yank code url",
      mode = { "n", "x" },
    },

    -- search
    {
      "<leader>sg",
      function()
        Snacks.picker.grep({ cwd = Snacks.git.get_root() })
      end,
      desc = "Git Files",
    },
    {
      "<leader>ss",
      function()
        Snacks.picker.grep({ dirs = { vim.fs.root(vim.api.nvim_get_current_buf(), { "service.yaml" }) } })
      end,
      desc = "Service",
    },
    {
      "<leader>sG",
      function()
        Snacks.picker.grep()
      end,
      desc = "Cwd",
    },
    {
      "<leader>sb",
      function()
        Snacks.picker.lines()
      end,
      desc = "Buffer Lines",
    },
    {
      "<leader>sB",
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = "Buffers Open",
    },
    {
      "<leader>sw",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Word",
      mode = { "n", "x" },
    },
    {
      '<leader>s"',
      function()
        Snacks.picker.registers()
      end,
      desc = "Registers",
    },
    {
      "<leader>s/",
      function()
        Snacks.picker.search_history()
      end,
      desc = "Search History",
    },
    {
      "<leader>sa",
      function()
        Snacks.picker.autocmds()
      end,
      desc = "Autocommands",
    },
    {
      "<leader>sb",
      function()
        Snacks.picker.lines()
      end,
      desc = "Buffer Lines",
    },
    {
      "<leader>sn",
      function()
        Snacks.picker.notifications()
      end,
      desc = "Notification History",
    },
    {
      "<leader>sc",
      function()
        Snacks.picker.command_history()
      end,
      desc = "Command History",
    },
    {
      "<leader>sC",
      function()
        Snacks.picker.commands()
      end,
      desc = "Commands",
    },
    {
      "<leader>sd",
      function()
        Snacks.picker.diagnostics()
      end,
      desc = "Diagnostics",
    },
    {
      "<leader>sD",
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = "Buffer Diagnostics",
    },
    {
      "<leader>sh",
      function()
        Snacks.picker.help()
      end,
      desc = "Help Pages",
    },
    {
      "<leader>sH",
      function()
        Snacks.picker.highlights()
      end,
      desc = "Highlights",
    },
    {
      "<leader>si",
      function()
        Snacks.picker.icons()
      end,
      desc = "Icons",
    },
    {
      "<leader>sj",
      function()
        Snacks.picker.jumps()
      end,
      desc = "Jumps",
    },
    {
      "<leader>sk",
      function()
        Snacks.picker.keymaps()
      end,
      desc = "Keymaps Neovim",
    },
    {
      "<leader>sK",
      function()
        Snacks.picker({
          finder = function(_, _)
            local file = os.getenv("HOME") .. "/personal/cheatsheet.csv"
            local lines = vim.fn.readfile(file)

            ---@type snacks.picker.finder.Item[] items to show instead of using a finder
            local items = {}
            for i, line in ipairs(lines) do
              local parts = vim.split(line, ",")
              if line ~= "" and #parts == 3 then
                local prog, desc, key = unpack(parts)
                table.insert(items, {
                  text = string.format("%-20s %-30s    %20s", prog, desc, key),
                })
              end
            end
            return items
          end,
          format = "text",
          title = "Keymaps",
          layout = {
            preset = "select",
            layout = {
              max_width = 80,
              max_height = 20,
            },
          },
        })
      end,
      desc = "Keymaps Programms",
    },
    {
      "<leader>sl",
      function()
        Snacks.picker.loclist()
      end,
      desc = "Location List",
    },
    {
      "<leader>sm",
      function()
        Snacks.picker.marks()
      end,
      desc = "Marks",
    },
    {
      "<leader>sM",
      function()
        Snacks.picker.man()
      end,
      desc = "Man Pages",
    },
    {
      "<leader>sp",
      function()
        Snacks.picker.lazy()
      end,
      desc = "Plugin Spec",
    },
    {
      "<leader>sq",
      function()
        Snacks.picker.qflist()
      end,
      desc = "Quickfix List",
    },
    {
      "<leader>sR",
      function()
        Snacks.picker.resume()
      end,
      desc = "Resume",
    },
    {
      "<leader>su",
      function()
        Snacks.picker.undo()
      end,
      desc = "Undo History",
    },
    {
      "<leader>sT",
      function()
        Snacks.picker.colorschemes()
      end,
      desc = "Themes",
    },
    -- Other
    {
      "<leader>bd",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete Buffer",
    },
    {
      "<leader>cR",
      function()
        Snacks.rename.rename_file()
      end,
      desc = "Rename File",
    },
    {
      "]]",
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = "Next Reference",
      mode = { "n", "t" },
    },
    {
      "[[",
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = "Prev Reference",
      mode = { "n", "t" },
    },
    {
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      desc = "Dismiss All Notifications",
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
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
        Snacks.toggle.animate():map("<leader>uA")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.line_number():map("<leader>ul")
        Snacks.toggle.scroll():map("<leader>us")
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>uS")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle
          .new({
            id = "treesitter-context",
            name = "Treesitter Context",
            get = function()
              return require("treesitter-context").enabled()
            end,
            set = function(state)
              if state then
                require("treesitter-context").enable()
              else
                require("treesitter-context").disable()
              end
            end,
          })
          :map("<leader>ut")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ui")
        Snacks.toggle.profiler():map("<leader>up")
        Snacks.toggle.profiler_highlights():map("<leader>uP")
        Snacks.toggle.dim():map("<leader>uD")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.words():map("<leader>uW")
        Snacks.toggle.zoom():map("<leader>uz")
        Snacks.toggle.zen():map("<leader>uZ")
        Snacks.toggle.zen():map("<leader>uZ")
      end,
    })
  end,
}
