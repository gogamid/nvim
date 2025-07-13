return {
  {
    -- "epwalsh/obsidian.nvim",
    "obsidian-nvim/obsidian.nvim",
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

      --editing
      -- { "<leader>fot", mode = { "n" }, "<cmd>ObsidianTemplate<cr>", desc = "Obsidian search" },
      { "<leader>oi", mode = { "n" }, "<cmd>ObsidianPasteImg<cr>", desc = "Obsidian Image paste" },
      { "<leader>or", mode = { "n" }, "<cmd>ObsidianRename<cr>", desc = "Obsidian Rename note" },

      --visual
      -- { "<leader>oe", mode = { "v" }, "<cmd>ObsidianExtractNote<cr>", desc = "Obsidian Extract to a note" },
      -- { "<leader>ol", mode = { "v" }, "<cmd>ObsidianLink<cr>", desc = "Obsidian Link to a note" },
      { "<leader>ol", mode = { "v" }, "<cmd>ObsidianLinkNew<cr>", desc = "Obsidian Link to a note" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      picker = {
        name = "snacks.pick",
      },
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
      mappings = {
        ["gf"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        ["<leader>ch"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { buffer = true },
        },
        -- Smart action depending on context: follow link, show notes with tag, toggle checkbox, or toggle heading fold
        ["<cr>"] = {
          action = function()
            return require("obsidian").util.smart_action()
          end,
          opts = { buffer = true, expr = true },
        },
      },
      ui = {
        enable = false,
      },
      -- other  defaults
      -- Sets how you follow URLs
      ---@param url string
      follow_url_func = function(url)
        vim.ui.open(url)
        -- vim.ui.open(url, { cmd = { "firefox" } })
      end,

      -- Sets how you follow images
      ---@param img string
      follow_img_func = function(img)
        vim.ui.open(img)
        -- vim.ui.open(img, { cmd = { "loupe" } })
      end,
      open = {},
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
