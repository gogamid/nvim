return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      -- TSReinstall {language} calls TSUninstall lang and TSInstall lang
      vim.api.nvim_create_user_command("TSReinstall", function(args)
        local lang = args.fargs[1]
        require("nvim-treesitter").uninstall({ lang }):wait(3000)
        vim.notify("Uninstalled " .. lang)
        require("nvim-treesitter").install({ lang }):wait(10000)
        vim.notify("Installed " .. lang)
      end, { nargs = 1 })

      require("nvim-treesitter").install("all")

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

      vim.filetype.add({
        extension = {
          apt = "gupta",
        },
        pattern = {
          [".*%.apt%.indented"] = "gupta",
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft

          local is_available = vim.tbl_contains(require("nvim-treesitter").get_available(), lang)
          if not is_available then
            return
          end

          vim.treesitter.start(args.buf)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
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
