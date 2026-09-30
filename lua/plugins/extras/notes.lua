return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    keys = {
      { "<leader>fo", "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian files" },
      { "<leader>fn", "<cmd>Obsidian new<cr>", desc = "New Note" },
    },
    opts = {
      legacy_commands = false,
      picker = {
        name = "snacks.picker",
      },
      workspaces = {
        {
          name = "general",
          path = os.getenv("HOME") .. "/work/notes",
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
    config = function(_, opts)
      require("obsidian").setup(opts)
    end,
  },
  {
    "backdround/global-note.nvim",
    opts = {
      filename = "Scratchpad.md",
      directory = os.getenv("HOME") .. "/work/notes",
      title = "notes",
      window_config = function()
        local w = 100
        local h = math.floor(vim.o.lines * 0.8)
        return {
          relative = "editor",
          border = "single",
          title_pos = "center",
          width = w,
          height = h,
          -- center
          col = vim.o.columns / 2 - w / 2,
          row = vim.o.lines / 2 - h / 2,
        }
      end,
      post_open = function(_, _)
        vim.schedule(function()
          vim.cmd("normal! Gzz")
        end)
      end,
    },
    keys = {
      { "<leader>n", "<cmd>GlobalNote<cr>", desc = "Global note" },
    },
    config = function(_, opts)
      require("global-note").setup(opts)
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      enabled = true,
      preset = "obsidian",
      heading = {
        icons = {},
      },
      anti_conceal = {
        enabled = false,
      },
    },
    ft = { "markdown", "norg", "rmd", "org", "codecompanion", "Avante" },
    keys = {
      { "<leader>um", ":RenderMarkdown toggle<cr>", desc = "Toggle Render Markdown" },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && bun install",
    keys = {
      { "<leader>uM", ":MarkdownPreviewToggle<cr>", desc = "Toggle Markdown Preview" },
    },
  },
}
