local function git_log_by_author()
  -- First, create a picker to select from git authors
  local function get_git_authors()
    local result = vim.fn.systemlist("git shortlog -sne --all")
    local authors = {}
    for _, line in ipairs(result) do
      -- Parse "123  Author Name <email@example.com>" format
      local count, author = line:match("^%s*(%d+)%s+(.+)$")
      if author then
        table.insert(authors, {
          text = author,
          author = author,
          count = tonumber(count) or 0,
        })
      end
    end
    return authors
  end

  Snacks.picker({
    items = get_git_authors(),
    format = function(item)
      return {
        { tostring(item.count), "Number" },
        { "  ", "Normal" },
        { item.author, "String" },
      }
    end,
    title = "Select Git Author",
    layout = { preset = "select" },
    confirm = function(picker, item)
      picker:close()
      -- Now show git log for selected author
      Snacks.picker.git_log({
        author = item.author,
        sort = { fields = { "date:desc", "score:desc", "idx" } },
      })
    end,
  })
end

local git_options = {
  actions = {
    ["diffview"] = function(picker)
      local currentCommit = picker:current().commit
      if currentCommit then
        local args = { currentCommit .. "^" .. "!" }
        require("diffview").open(args)
      end
    end,
    ["copy_pr_url"] = function(picker)
      local currentMsg = picker:current().msg
      if currentMsg then
        local pr_number = string.match(currentMsg, "Merged PR (%d+):")
        if pr_number then
          local url = string.format("%s/%s", os.getenv("AZURE_PR_URL"), pr_number)
          vim.fn.setreg("+", url)
        else
          print("PR number not found in message.")
        end
      end
    end,
    ["open_pr"] = function(picker)
      local currentMsg = picker:current().msg
      if currentMsg then
        local pr_number = string.match(currentMsg, "Merged PR (%d+):")
        if pr_number then
          local url = string.format(
            "https://dev.azure.com/schwarzit/lidl.wawi-core/_git/fd801c1d-643e-47f4-ad9d-2efc5db0fc03/pullrequest/%s",
            pr_number
          )
          vim.fn.system({ "open", url })
        else
          print("PR number not found in message.")
        end
      end
    end,
  },
  win = {
    input = {
      keys = {
        ["<CR>"] = { "diffview", desc = "Diffview this commit", mode = { "n", "i" } },
        ["<C-c>"] = { "git_checkout", desc = "Checkout commit", mode = { "n", "i" } },
        ["<C-y>"] = { "copy_pr_url", desc = "Copy PR URL", mode = { "n", "i" } },
        ["<C-o>"] = { "open_pr", desc = "Open PR", mode = { "n", "i" } },
      },
    },
  },
}

local picker_options = {
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
      enabled = true,
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
    indent = { enabled = true },
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
    { "<leader>ga", git_log_by_author, desc = "Author Logs" },
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
    {
      "<leader>gd",
      function()
        Snacks.picker.git_diff()
      end,
      desc = "Diffs",
    },
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
      desc = "Keymaps",
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
      "<leader>z",
      function()
        Snacks.zen()
      end,
      desc = "Toggle Zen Mode",
    },
    {
      "<leader>Z",
      function()
        Snacks.zen.zoom()
      end,
      desc = "Toggle Zoom",
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
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.line_number():map("<leader>ul")
        -- Snacks.toggle
        --   .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
        --   :map("<leader>uC")
        Snacks.toggle.treesitter():map("<leader>uT")
        Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,
}
