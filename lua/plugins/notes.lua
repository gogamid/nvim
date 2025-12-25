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
    opts = {
      filename = "Scratchpad.md",
      directory = "~/work/obsidian/work",
      title = "Scratchpad",
      window_config = function()
        local w = math.floor(vim.o.columns * 0.4)
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
      post_open = function(a, b)
        vim.cmd("normal! Gzz")
      end,
    },
    keys = {
      { "<leader>n", mode = { "n" }, "<cmd>GlobalNote<cr>", desc = "Global note" },
    },
  },
}
