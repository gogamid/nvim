return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        sign = false,
      },
    },
    ft = { "markdown", "norg", "rmd", "org", "codecompanion", "Avante" },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      Snacks.toggle({
        name = "Render Markdown",
        get = function()
          return require("render-markdown.state").enabled
        end,
        set = function(enabled)
          local m = require("render-markdown")
          if enabled then
            m.enable()
          else
            m.disable()
          end
        end,
      }):map("<leader>um")
    end,
  },
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    keys = {
      { "<leader>fo", mode = { "n" }, "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian files" },
      { "<leader>fn", mode = { "n" }, "<cmd>Obsidian new<cr>", desc = "New Note" },
    },
    opts = {
      legacy_commands = false,
      picker = {
        name = "snacks.pick",
      },
      workspaces = {
        {
          name = "work",
          path = "~/work/obsidian/work",
        },
      },
      note_id_func = function(title)
        if title == nil then
          title = "untitled"
        end
        return tostring(os.time()) .. "-" .. title
      end,
      open_notes_in = "vsplit",
      frontmatter = {
        enabled = false,
      },
      ui = {
        enable = false,
      },
      footer = {
        enabled = false,
      },
      checkbox = {
        order = { " ", "x" },
      },
      comment = {
        enabled = true,
      },
    },
  },
  {
    "backdround/global-note.nvim",
    config = function(_, opts)
      local global_note = require("global-note")
      opts.filename = "Scratchpad.md"
      opts.directory = "~/work/obsidian/work"
      opts.title = "Scratchpad"

      opts.post_open = function(_, _)
        vim.cmd("normal! Gzz")
      end
      global_note.setup(opts)
      vim.keymap.set("n", "<leader>n", global_note.toggle_note, {
        desc = "Toggle global note",
      })
    end,
  },
  {
    "backdround/global-note.nvim",
    opts = {
      -- Filename to use for default note (preset).
      -- string or fun(): string
      filename = "Scratchpad.md",

      -- Directory to keep default note (preset).
      -- string or fun(): string
      directory = "~/work/obsidian/work",

      -- Floating window title.
      -- string or fun(): string
      title = "Scratchpad",

      -- Ex command name.
      -- string
      command_name = "GlobalNote",

      -- A nvim_open_win config to show float window.
      -- table or fun(): table
      window_config = function()
        local window_height = vim.api.nvim_list_uis()[1].height
        local window_width = vim.api.nvim_list_uis()[1].width
        return {
          relative = "editor",
          border = "single",
          title = "Note",
          title_pos = "center",
          width = math.floor(0.7 * window_width),
          height = math.floor(0.85 * window_height),
          row = math.floor(0.05 * window_height),
          col = math.floor(0.15 * window_width),
        }
      end,

      -- It's called after the window creation.
      -- fun(buffer_id: number, window_id: number)
      post_open = function(_, _) end,

      -- Whether to use autosave. Autosave saves buffer on closing window
      -- or exiting Neovim.
      -- boolean
      autosave = true,

      -- Additional presets to create other global, project local, file local
      -- and other notes.
      -- { [name]: table } - tables there have the same fields as the current table.
      additional_presets = {},
    },
  },
}
