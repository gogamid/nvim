local actions = require("telescope.actions")
return {
  {
    "nvim-telescope/telescope.nvim",
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
      {
        "<leader>/",
        "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
        desc = "Grep (root dir)",
      },
      {
        "<leader>fP",
        function()
          require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root })
        end,
        desc = "Find Plugin File",
      },
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
            },
          },
        },
      }
      tele.setup(opts)
      tele.load_extension("live_grep_args")
    end,
  },
}
