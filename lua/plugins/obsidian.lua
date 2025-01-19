return {
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    keys = {
      { "<leader>on", mode = { "n" }, "<cmd>ObsidianNew<cr>", desc = "Obsidian new note" },
      -- { "<leader>fos", mode = { "n" }, "<cmd>ObsidianNewFromTemplate<cr>", desc = "Obsidian search" },

      --search
      { "<leader>os", mode = { "n" }, "<cmd>ObsidianSearch<cr>", desc = "Obsidian search" },
      { "<leader>of", mode = { "n" }, "<cmd>ObsidianQuickSwitch<cr>", desc = "Obsidian Files" },
      { "<leader>ob", mode = { "n" }, "<cmd>ObsidianBacklinks<cr>", desc = "Obsidian Backlinks" },
      { "<leader>og", mode = { "n" }, "<cmd>ObsidianTags<cr>", desc = "Obsidian Tags" },
      { "<leader>ol", mode = { "n" }, "<cmd>ObsidianLinks<cr>", desc = "Obsidian Links in current buffer" },
      { "<leader><cr>", mode = { "n" }, "<cmd>ObsidianFollowLink<cr>", desc = "Obsidian Follow link" },

      --daily
      { "<leader>od", mode = { "n" }, "<cmd>ObsidianDailies<cr>", desc = "Obsidian Dailies" },
      { "<leader>ot", mode = { "n" }, "<cmd>ObsidianToday<cr>", desc = "Obsidian Today Daily" },
      { "<leader>op", mode = { "n" }, "<cmd>ObsidianYesterday<cr>", desc = "Obsidian Previous Daily" },
      { "<leader>oa", mode = { "n" }, "<cmd>ObsidianTomorrow<cr>", desc = "Obsidian After Daily" },

      --editing
      -- { "<leader>fot", mode = { "n" }, "<cmd>ObsidianTemplate<cr>", desc = "Obsidian search" },
      { "<leader>oi", mode = { "n" }, "<cmd>ObsidianPasteImg<cr>", desc = "Obsidian Image paste" },
      { "<leader>or", mode = { "n" }, "<cmd>ObsidianRename<cr>", desc = "Obsidian Rename note" },

      --visual
      -- { "<leader>oe", mode = { "v" }, "<cmd>ObsidianExtractNote<cr>", desc = "Obsidian Extract to a note" },
      -- { "<leader>ol", mode = { "v" }, "<cmd>ObsidianLink<cr>", desc = "Obsidian Link to a note" },
      { "<leader>ol", mode = { "v" }, "<cmd>ObsidianLinkNew<cr>", desc = "Obsidian Link to a note" },
    },
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "work",
          path = "~/work/obsidian/work",
        },
      },
      completion = {
        blink = true,
        min_chars = 2,
      },
      daily_notes = {
        folder = "journal",
        date_format = "%d-%m-%Y",
      },
      mappings = {
        ["<leader>ch"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { buffer = true },
        },
      },
      ui = {
        enable = false,
      },
      note_id_func = function(title)
        local suffix = ""
        if title ~= nil then
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. "-" .. suffix
      end,
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
