return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
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
          -- "go",
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
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.go = {
        install_info = {
          url = "/Users/gamidli/personal/tree-sitter-go", -- your local path
          files = { "src/parser.c" },
          -- optional entries:
          branch = "master",
          generate_requires_npm = false,
          requires_generate_from_grammar = false, -- you have pre-generated src/parser.c
        },
        filetype = "go", -- Gupta files typically use .apt extension
      }
    end,
  },
}
