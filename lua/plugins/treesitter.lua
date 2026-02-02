return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local filetypes = {
        "bash",
        "c",
        "diff",
        "html",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "query",
        "vim",
        "vimdoc",
        "go",
        "vue",
        "typescript",
        "javascript",
      }
      require("nvim-treesitter").install(filetypes)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = filetypes,
        callback = function()
          vim.treesitter.start()
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          ---@diagnostic disable-next-line: missing-fields
          require("nvim-treesitter.parsers").go = {
            ---@diagnostic disable-next-line: missing-fields
            install_info = {
              path = "~/personal/tree-sitter-go",
            },
          }

          require("nvim-treesitter.parsers").gupta = {
            filetype = "gupta",
            install_info = {
              path = "~/personal/tree-sitter-gupta",
              generate = false,
              queries = "queries",
            },
          }
        end,
      })
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
