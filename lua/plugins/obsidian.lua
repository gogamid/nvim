return {
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
      nvim_cmp = true,
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
}
