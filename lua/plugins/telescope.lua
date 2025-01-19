local function find_git_root()
  -- Use the current buffer's path as the starting point for the git search
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  -- If the buffer is not associated with a file, return nil
  if current_file == "" then
    current_dir = cwd
  else
    -- Extract the directory from the current file's path
    current_dir = vim.fn.fnamemodify(current_file, ":h")
  end

  -- Find the Git root directory from the current file's path
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.escape(current_dir, " ") .. " rev-parse --show-toplevel")[1]
  if vim.v.shell_error ~= 0 then
    print("Not a git repository. Searching on current working directory")
    return cwd
  end
  return git_root
end
local actions = require("telescope.actions")
return {
  {
    "nvim-telescope/telescope.nvim",
    enabled = false,
    dependencies = {
      {
        "nvim-telescope/telescope-live-grep-args.nvim",
      },
    },
    opts = {
      defaults = {
        layout_strategy = "vertical",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        path_display = {
          "filename_first",
        },
      },
      pickers = {
        buffers = {
          mappings = {
            n = {
              ["<C-x>"] = actions.delete_buffer,
            },
            i = {
              ["<C-x>"] = actions.delete_buffer,
            },
          },
        },
      },
    },
    keys = {
      -- {
      --   "<leader>/",
      --   function()
      --     local git_root = find_git_root()
      --     if git_root then
      --       require("telescope").extensions.live_grep_args.live_grep_args({
      --         search_dirs = { git_root },
      --       })
      --     else
      --       require("telescope").extensions.live_grep_args.live_grep_args()
      --     end
      --   end,
      --   desc = "Grep (git root)",
      -- },
      -- -- {
      --   "<leader>fP",
      --   function()
      --     require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
      --   end,
      --   desc = "Find Plugin File",
      -- },
    },
    config = function(_, opts)
      local tele = require("telescope")

      local lga_actions = require("telescope-live-grep-args.actions")

      opts.extensions = {
        live_grep_args = {
          auto_quoting = true, -- enable/disable auto-quoting
          -- define mappings, e.g.
          mappings = { -- extend mappings
            i = {
              ["<C-k>"] = lga_actions.quote_prompt(),
              ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
              -- freeze the current list and start a fuzzy search in the frozen list
              ["<C-space>"] = actions.to_fuzzy_refine,
            },
          },
        },
      }
      tele.setup(opts)
      tele.load_extension("live_grep_args")
    end,
  },
}
