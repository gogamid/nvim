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
  -- TODO: do not show 0-9 marks
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

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
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
    },
  },
  keys = {
    {
      "<leader><space>",
      function()
        Snacks.picker.smart()
      end,
      desc = "Smart Find Files",
    },
    {
      "<leader>fs",
      function()
        Snacks.picker.files({
          dirs = { vim.fs.root(vim.api.nvim_get_current_buf(), { "service.yaml" }) },
        })
      end,
      desc = "find files in the service",
    },
    {
      "<leader>gt",
      function()
        Snacks.picker.pick("git_branches")
      end,
      desc = "Git branches",
    },
    {
      "<leader>fz",
      function()
        Snacks.picker.zoxide({})
      end,
      desc = "Zoxide folders",
    },
    {
      "<leader>fg",
      function()
        Snacks.picker.git_files({
          finder = "git_files",
          show_empty = true,
          format = "file",
          cwd = LazyVim.root.git(),
        })
      end,
      desc = "Find Files (git-files)",
    },
    {
      "<leader>/",
      function()
        Snacks.picker.grep({
          finder = "grep",
          format = "file",
          show_empty = true,
          live = true,
          supports_live = true,
          dirs = { LazyVim.root.git() },
          regex = false,
        })
      end,
      desc = "Grep (git root)",
    },
    {
      "<leader>fP",
      function()
        Snacks.picker.files({
          show_empty = true,
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
    {
      "<leader>ga",
      function()
        local input = vim.fn.input("Author: ")
        Snacks.picker.git_log({ author = input, confirm = "diffview" })
      end,
      desc = "Git Logs by [A]uthor",
    },
  },
}
