local gitOptions = {
  actions = {
    ["diffview"] = function(picker)
      local currentCommit = picker:current().commit
      picker:close()
      if currentCommit then
        local args = { currentCommit .. "^" .. "!" }
        require("diffview").open(args)
      end
    end,
  },
  win = {
    input = {
      keys = {
        ["<CR>"] = {
          "diffview",
          desc = "Diffview this commit",
          mode = { "n", "i" },
        },
      },
    },
  },
}

local marksOptions = {
  actions = {
    ["delete_mark"] = function(picker)
      picker.preview:reset()
      local currentMark = picker:current()
      local label = currentMark and currentMark.label
      if label and label == label:lower() then
        vim.api.nvim_buf_del_mark(0, label)
      elseif label then
        vim.api.nvim_del_mark(label)
      end
      picker.list:set_selected()
      picker.list:set_target()
      picker:find()
    end,
  },
  win = {
    input = {
      keys = {
        ["<C-x>"] = {
          "delete_mark",
          desc = "Delete mark",
          mode = { "n", "i" },
        },
      },
    },
  },
  ["local"] = false,
}

local pickerInputKeys = {
  ["<a-d>"] = false,
  ["<c-i>"] = { "inspect", mode = { "n", "i" } },

  ["<c-l>"] = { "select_and_next", mode = { "n", "i" } },
  ["<c-a>"] = { "select_all", mode = { "n", "i" } },

  ["<a-m>"] = false,
  ["<c-z>"] = { "toggle_maximize", mode = { "n", "i" } },

  ["<a-p>"] = false,
  ["<c-t>"] = { "toggle_preview", mode = { "i", "n" } },

  ["<a-w>"] = false,
  ["<c-e>"] = { "cycle_win", mode = { "i", "n" } },
  ["<C-w>"] = { "<c-s-w>", mode = { "i" }, expr = true, desc = "delete word" },

  ["<C-Up>"] = false,
  ["<C-Down>"] = false,
  ["<c-j>"] = { "history_back", mode = { "i", "n" } },
  ["<c-k>"] = { "history_forward", mode = { "i", "n" } },

  ["<Tab>"] = false,
  ["<S-Tab>"] = false,
  --
  ["<Down>"] = false,
  ["<Up>"] = false,

  -- ["<c-j>"] = { "list_down", mode = { "i", "n" } },
  -- ["<c-k>"] = { "list_up", mode = { "i", "n" } },

  ["<a-i>"] = false,
  ["<a-h>"] = false,
  ["<c-,>"] = { "toggle_ignored", mode = { "i", "n" } },
  ["<c-.>"] = { "toggle_hidden", mode = { "i", "n" } },
}
local picker_options = {
  sources = {
    explorer = {
      -- layout = { layout = { position = "float", preview = true } },
      layout = { preset = "telescope", preview = true, reverse = false },
      auto_close = true,
      -- jump = { close = true },
      formatters = { file = { filename_only = true } },
      matcher = {
        regex = true,
        fuzzy = false, -- use fuzzy matching
      },
    },
    git_log = gitOptions,
    git_log_file = gitOptions,
    git_log_line = gitOptions,
    marks = marksOptions,
  },
  win = {
    -- input window
    input = {
      keys = pickerInputKeys,
      b = {
        minipairs_disable = true,
      },
    },
    -- result list window
    list = {
      keys = {

        ["<Tab>"] = false,
        ["<S-Tab>"] = false,
        --
        ["<Down>"] = false,
        ["<Up>"] = false,
        ["<c-i>"] = "inspect",
        -- ["<c-l>"] = "select_all",
        ["<c-f>"] = "preview_scroll_down",
        ["<c-b>"] = "preview_scroll_up",
      },
    },
    -- preview window
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
  -- layout = { preset = "telescope", preview = true },
  layout = { preset = "default" },
  layouts = {
    default = {
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
  ---@type snacks.Config
  opts = {
    picker = picker_options,
    image = {},
    dashboard = {
      preset = {
        keys = {},
        header = require("config.headers").neovim,
      },
      formats = { key = { "" } },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
      },
    },
    lazygit = {
      win = {
        width = 0.99,
        height = 0.99,
      },
    },
    terminal = {
      win = {
        position = "float",
        relative = "editor",
        backdrop = 60,
        border = "rounded",
        height = 0.8,
        width = 0.95,
        zindex = 50,
        keys = {
          q = "close",
        },
      },
    },
    bigfile = { enabled = false },
    notifier = {
      enabled = true,
      timeout = 3000,
      margin = { top = 0, right = 1, bottom = 1, left = 0 },
      top_down = false,
    },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    styles = {
      notification = {
        wo = { wrap = true }, -- Wrap notifications
      },
    },
    zen = {
      toggles = { dim = false },
    },
    input = { enabled = true },
    gitbrowse = {
      url_patterns = {
        ["dev%.azure%.com"] = {
          file = "?path=/{file}&version=GB{branch}&line={line_start}&lineEnd={line_end}&lineStartColumn=1&lineEndColumn=1&lineStyle=plain&_a=contents",
          commit = "/commit/{commit}",
          branch = "",
        },
      },
    },
    explorer = { enabled = false },
    indent = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false },
    words = { enabled = false },
  },
    --stylua: ignore
    keys = {
        -- Top Pickers & Explorer
        { "<leader>N",  function() Snacks.picker.notifications() end,                                                                                desc = "Notification History" },
        -- find
        { "<leader>ff", function() Snacks.picker.files() end,                                                                                        desc = "Find Files Cwd" },
        { "<leader>fg", function() Snacks.picker.git_files() end,                                                                                    desc = "Find Git Files" },
        { "<leader>fs", function() Snacks.picker.files({ dirs = { vim.fs.root(vim.api.nvim_get_current_buf(), { "service.yaml", ".git" }) }, }) end, desc = "find files in the service", },
        { "<leader>fb", function() Snacks.picker.buffers() end,                                                                                      desc = "Buffers" },
        { "<leader>,",  function() Snacks.picker.buffers() end,                                                                                      desc = "Buffers" },
        { "<leader>fr", function() Snacks.picker.recent() end,                                                                                       desc = "Recent" },
        { "<leader>fP", function() Snacks.picker.files({ cwd = require("lazy.core.config").options.root }) end,                                      desc = "Find Plugin File" },
        { "<leader>fz", function() Snacks.picker.zioxide() end,                                                                                      desc = "Zoxide folders" },
        { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end,                                                      desc = "Find Config File" },
        -- git
        { "<leader>ga", function() Snacks.picker.git_log({ author = vim.fn.input("Author:"), confirm = "diffview" }) end,                            desc = "Git Logs by [A]uthor", },
        { "<leader>gl", function() Snacks.picker.git_log() end,                                                                                      desc = "Git Log" },
        { "<leader>gb", function() Snacks.picker.git_log_line() end,                                                                                 desc = "Git Blame Line" },
        { "<leader>gf", function() Snacks.picker.git_log_file() end,                                                                                 desc = "Git Log File" },
        { "<leader>gs", function() Snacks.picker.git_status() end,                                                                                   desc = "Git Status" },
        { "<leader>gd", function() Snacks.picker.git_diff() end,                                                                                     desc = "Git Diff (Hunks)" },
        -- Grep
        { "<leader>/",  function() Snacks.picker.grep({ cwd = Snacks.git.get_root() }) end,                                                          desc = "Grep Git Files" },
        { "<leader>sg", function() Snacks.picker.grep({ dirs = { vim.fs.root(vim.api.nvim_get_current_buf(), { "service.yaml" }) } }) end,           desc = "Grep Service" },
        { "<leader>sG", function() Snacks.picker.grep() end,                                                                                         desc = "Grep Cwd" },
        { "<leader>sb", function() Snacks.picker.lines() end,                                                                                        desc = "Buffer Lines" },
        { "<leader>sB", function() Snacks.picker.grep_buffers() end,                                                                                 desc = "Grep Open Buffers" },
        { "<leader>sw", function() Snacks.picker.grep_word() end,                                                                                    desc = "Visual selection or word",  mode = { "n", "x" } },
        -- search
        { '<leader>s"', function() Snacks.picker.registers() end,                                                                                    desc = "Registers" },
        { '<leader>s/', function() Snacks.picker.search_history() end,                                                                               desc = "Search History" },
        { "<leader>sa", function() Snacks.picker.autocmds() end,                                                                                     desc = "Autocmds" },
        { "<leader>sb", function() Snacks.picker.lines() end,                                                                                        desc = "Buffer Lines" },
        { "<leader>sc", function() Snacks.picker.command_history() end,                                                                              desc = "Command History" },
        { "<leader>sC", function() Snacks.picker.commands() end,                                                                                     desc = "Commands" },
        { "<leader>sd", function() Snacks.picker.diagnostics() end,                                                                                  desc = "Diagnostics" },
        { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end,                                                                           desc = "Buffer Diagnostics" },
        { "<leader>sh", function() Snacks.picker.help() end,                                                                                         desc = "Help Pages" },
        { "<leader>sH", function() Snacks.picker.highlights() end,                                                                                   desc = "Highlights" },
        { "<leader>si", function() Snacks.picker.icons() end,                                                                                        desc = "Icons" },
        { "<leader>sj", function() Snacks.picker.jumps() end,                                                                                        desc = "Jumps" },
        { "<leader>sk", function() Snacks.picker.keymaps() end,                                                                                      desc = "Keymaps" },
        { "<leader>sl", function() Snacks.picker.loclist() end,                                                                                      desc = "Location List" },
        { "<leader>sm", function() Snacks.picker.marks() end,                                                                                        desc = "Marks" },
        { "<leader>sM", function() Snacks.picker.man() end,                                                                                          desc = "Man Pages" },
        { "<leader>sp", function() Snacks.picker.lazy() end,                                                                                         desc = "Search for Plugin Spec" },
        { "<leader>sq", function() Snacks.picker.qflist() end,                                                                                       desc = "Quickfix List" },
        { "<leader>sR", function() Snacks.picker.resume() end,                                                                                       desc = "Resume" },
        { "<leader>su", function() Snacks.picker.undo() end,                                                                                         desc = "Undo History" },
        { "<leader>uC", function() Snacks.picker.colorschemes() end,                                                                                 desc = "Colorschemes" },
        -- LSP
        { "gd",         function() Snacks.picker.lsp_definitions() end,                                                                              desc = "Goto Definition" },
        { "gD",         function() Snacks.picker.lsp_declarations() end,                                                                             desc = "Goto Declaration" },
        { "gr",         function() Snacks.picker.lsp_references() end,                                                                               nowait = true,                      desc = "References" },
        { "gi",         function() Snacks.picker.lsp_implementations() end,                                                                          desc = "Goto Implementation" },
        { "gy",         function() Snacks.picker.lsp_type_definitions() end,                                                                         desc = "Goto T[y]pe Definition" },
        { "<leader>ss", function() Snacks.picker.lsp_symbols() end,                                                                                  desc = "LSP Symbols" },
        { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end,                                                                        desc = "LSP Workspace Symbols" },
        -- Other
        { "<leader>z",  function() Snacks.zen() end,                                                                                                 desc = "Toggle Zen Mode" },
        { "<leader>Z",  function() Snacks.zen.zoom() end,                                                                                            desc = "Toggle Zoom" },
        { "<leader>bd", function() Snacks.bufdelete() end,                                                                                           desc = "Delete Buffer" },
        { "<leader>cR", function() Snacks.rename.rename_file() end,                                                                                  desc = "Rename File" },
        { "<leader>gB", function() Snacks.gitbrowse() end,                                                                                           desc = "Git Browse",                mode = { "n", "v" } },
        { "<leader>gg", function() Snacks.lazygit() end,                                                                                             desc = "Lazygit" },
        { "<leader>un", function() Snacks.notifier.hide() end,                                                                                       desc = "Dismiss All Notifications" },
        { "<c-/>",      function() Snacks.terminal() end,                                                                                            desc = "Toggle Terminal" },
        { "<c-_>",      function() Snacks.terminal() end,                                                                                            desc = "which_key_ignore" },
        { "]]",         function() Snacks.words.jump(vim.v.count1) end,                                                                              desc = "Next Reference",            mode = { "n", "t" } },
        { "[[",         function() Snacks.words.jump(-vim.v.count1) end,                                                                             desc = "Prev Reference",            mode = { "n", "t" } },
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
