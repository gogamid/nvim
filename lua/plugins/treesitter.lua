return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
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
      })
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.go = {
        install_info = {
          url = "/Users/gamidli/personal/tree-sitter-go",
          files = { "src/parser.c" },
          branch = "master",
          generate_requires_npm = false,
          requires_generate_from_grammar = false,
        },
        filetype = "go",
      }
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = {
      select = {
        lookahead = true,
        selection_modes = {
          ["@function.outer"] = "v",
        },
      },
    },
    keys = {
      {
        "af",
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
        end,
        desc = "around function",
        mode = { "x", "o" },
      },
      {
        "if",
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
        end,
        desc = "inner part of function",
        mode = { "x", "o" },
      },
      {
        "]f",
        function()
          require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
        end,
        desc = "next function",
        mode = { "n", "x", "o" },
      },
      {
        "[f",
        function()
          require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
        end,
        desc = "previous function",
        mode = { "n", "x", "o" },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      mode = "cursor",
      max_lines = 3,
    },
  },
}
