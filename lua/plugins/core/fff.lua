local function parent_dir()
  return vim.fs.dirname(vim.api.nvim_buf_get_name(0))
end

local function git_root()
  return vim.fs.root(0, { ".git" })
end

return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    require("fff.download").download_or_build_binary()
  end,
  opts = {
    wrap_around = true,
    debug = {
      enabled = false,
      show_scores = false,
    },
    git = {
      status_text_color = true,
    },
    layout = {
      prompt_position = "top",
    },
    grep = {
      modes = { "plain", "regex", "fuzzy" },
      enable_filename_constraint = true,
    },
  },
  lazy = false,
  keys = {
    -- Files (1:1 with snacks picker)
    {
      "<leader>ff",
      function()
        require("fff").find_files()
      end,
      desc = "Find files",
    },
    {
      "<leader>fg",
      function()
        local dir = git_root()
        if dir then
          require("fff").find_files_in_dir(dir)
        else
          require("fff").find_files()
        end
      end,
      desc = "Find files (git repo)",
    },
    -- Grep (migrated from snacks picker)
    {
      "<leader>sf",
      function()
        require("fff").live_grep()
      end,
      desc = "Grep cwd",
    },
    {
      "<leader>sg",
      function()
        local dir = git_root()
        if dir then
          require("fff").live_grep({ cwd = dir })
        else
          require("fff").live_grep()
        end
      end,
      desc = "Git grep",
    },
    {
      "<leader>sp",
      function()
        require("fff").live_grep({ cwd = parent_dir() })
      end,
      desc = "Parent dir grep",
    },
  },
}
