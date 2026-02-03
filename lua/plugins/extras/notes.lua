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
    opts = {
      filename = "Scratchpad.md",
      directory = "~/work/obsidian/work",
      title = "Scratchpad",
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
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        sign = false,
      },
    },
    ft = { "markdown", "norg", "rmd", "org", "codecompanion", "Avante" },
    keys = {
      { "<leader>um", ":RenderMarkdown toggle<cr>", desc = "Toggle Render Markdown" },
    },
  },
}
