return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      {
        "nvim-treesitter/nvim-treesitter-context",
        opts = {
          mode = "cursor",
          max_lines = 3,
        },
      },
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "markdown",
          "go",
          "lua",
        },
        ignore_install = {},
        sync_install = true,
        modules = {},
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        auto_install = true,
        textobjects = {
          enable = true,
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = { query = "@function.outer", desc = "around a function" },
              ["if"] = { query = "@function.inner", desc = "inner part of a function" },
            },
            selection_modes = {
              ["@function.outer"] = "v",
            },
            include_surrounding_whitespace = false,
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_previous_start = {
              ["[f"] = { query = "@function.outer", desc = "Previous function" },
            },
            goto_next_start = {
              ["]f"] = { query = "@function.outer", desc = "Next function" },
            },
          },
        },
      })
    end,
    keys = {
      -- { "<leader>uI", ":InspectTree<CR>", desc = "Inspect Tree" },
      -- { "<leader>uE", ":EditQuery<CR>", desc = "Edit Query" },
      {
        "<leader>uI",
        function()
          vim.cmd("InspectTree")
          vim.cmd("EditQuery")
        end,
        desc = "Inspect and Edit Query",
      },
    },
  },
}
