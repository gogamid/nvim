return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>n", false },
      {
        "<leader>gt",
        function()
          Snacks.picker.pick("git_branches", {})
        end,
        desc = "Git branches",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.git_files({ cwd = LazyVim.root.git() })
        end,
        desc = "Find Files (git-files)",
      },
      {
        "<leader>/",
        function()
          Snacks.picker.grep({
            finder = "grep",
            format = "file",
            live = true, -- live grep by default
            supports_live = true,
            dirs = { LazyVim.root.git() },
            regex = true,
          })
        end,
        desc = "Grep (git root)",
      },
      {
        "<leader>fz",
        function()
          Snacks.picker.zoxide({})
        end,
        desc = "Zoxide folders",
      },
      {
        "<leader>fP",
        function()
          Snacks.picker.files({
            finder = "files",
            format = "file",
            hidden = false,
            ignored = false,
            follow = false,
            supports_live = true,
            cwd = require("lazy.core.config").options.root,
          })
        end,
        desc = "Find Plugin File",
      },
    },
    opts = {
      dashboard = {
        enabled = true,
        preset = {
          header = [[ 
                                                                       
         ████ ██████           █████      ██                     
        ███████████             █████                             
        █████████ ███████████████████ ███   ███████████   
       ███:)████  ███    █████████████ █████ ██████████████   
      █████████ ██████████ █████████ █████ █████ ████ █████   
    ███████████ ███    ███ █████████ █████ █████ ████ █████  
   ██████  █████████████████████ ████ █████ █████ ████ ██████ 
                                                                         
]],
        },
        sections = {
          -- { section = "terminal", cmd = "fortune -s", hl = "header", padding = 1, indent = 8 },
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
          -- { section = "terminal", cmd = "fortune -s ", hl = "header", indent = 6 },
        },
      },
      lazygit = {
        win = {
          width = 0.9,
          height = 0.9,
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
      bigfile = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
        margin = { top = 0, right = 1, bottom = 1, left = 0 },
        top_down = false,
      },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      styles = {
        notification = {
          wo = { wrap = true }, -- Wrap notifications
        },
      },
      zen = {
        enabled = true,
      },
      input = {
        enabled = true,
        backdrop = false,
        position = "float",
        border = "rounded",
        title_pos = "left",
        height = 1,
        width = 60,
        relative = "editor",
        row = 2,
        -- relative = "cursor",
        -- row = -3,
        -- col = 0,
        wo = {
          winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
        },
        keys = {
          i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "i" },
          -- i_esc = { "<esc>", "stopinsert", mode = "i" },
          i_cr = { "<cr>", { "cmp_accept", "confirm" }, mode = "i" },
          i_tab = { "<tab>", { "cmp_select_next", "cmp" }, mode = "i" },
          q = "cancel",
        },
      },
      gitbrowse = {
        url_patterns = {
          ["dev%.azure%.com"] = {
            file = "?path=/{file}&version=GB{branch}&line={line_start}&lineEnd={line_end}&lineStartColumn=1&lineEndColumn=1&lineStyle=plain&_a=contents",
            commit = "/commit/{commit}",
            branch = "",
          },
        },
      },
      picker = {
        win = {
          -- input window
          input = {
            keys = {
              ["<a-d>"] = false,
              ["<c-i>"] = { "inspect", mode = { "n", "i" } },

              ["<c-a>"] = false,
              ["<c-l>"] = { "select_all", mode = { "n", "i" } },

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
            },
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
              ["<c-l>"] = "select_all",
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
        layout = {
          preset = "default",
        },
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
        -- preset = "ivy",

        -- - default                                    |snacks-picker-layouts-default|
        -- - dropdown                                  |snacks-picker-layouts-dropdown|
        -- - ivy                                            |snacks-picker-layouts-ivy|
        -- - select                                      |snacks-picker-layouts-select|
        -- - telescope                                |snacks-picker-layouts-telescope|
        -- - vertical                                  |snacks-picker-layouts-vertical|
        -- - vscode                                      |snacks-picker-layouts-vscode|
        formatters = {
          file = {
            filename_first = true,
          },
        },
      },
    },
  },
}
