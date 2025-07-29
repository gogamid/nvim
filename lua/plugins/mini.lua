return {
  {
    "echasnovski/mini.files",
    lazy = false,
    opts = {
      mappings = {
        close = "q",
        go_in = "L",
        go_in_plus = "l",
        go_out = "h",
        go_out_plus = "H",
        mark_goto = "'",
        mark_set = "m",
        reset = "<BS>",
        reveal_cwd = "@",
        show_help = "g?",
        synchronize = "=",
        trim_left = "<",
        trim_right = ">",
      },
      windows = {
        max_number = 2,
        preview = true,
        width_focus = 60,
        width_preview = 60,
      },
      options = {
        -- replaces netrw
        use_as_default_explorer = true,
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = "Open mini.files (Directory of Current File)",
      },
    },
    config = function(_, opts)
      require("mini.files").setup(opts)

      local show_dotfiles = true
      local filter_show = function(fs_entry)
        return true
      end
      local filter_hide = function(fs_entry)
        return not vim.startswith(fs_entry.name, ".")
      end

      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        require("mini.files").refresh({ content = { filter = new_filter } })
      end

      local files_set_cwd = function()
        local cur_entry_path = MiniFiles.get_fs_entry().path
        local cur_directory = vim.fs.dirname(cur_entry_path)
        if cur_directory ~= nil then
          vim.fn.chdir(cur_directory)
        end
      end

      -- Yank in register full path of entry under cursor
      local yank_path = function()
        local path = (MiniFiles.get_fs_entry() or {}).path
        if path == nil then
          return vim.notify("Cursor is not on valid entry")
        end
        vim.fn.setreg(vim.v.register, path)
      end

      -- Open path with system default handler (useful for non-text files)
      local ui_open = function()
        vim.ui.open(MiniFiles.get_fs_entry().path)
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id

          vim.keymap.set(
            "n",
            opts.mappings and opts.mappings.toggle_hidden or "g.",
            toggle_dotfiles,
            { buffer = buf_id, desc = "Toggle hidden files" }
          )

          vim.keymap.set(
            "n",
            opts.mappings and opts.mappings.change_cwd or "gc",
            files_set_cwd,
            { buffer = args.data.buf_id, desc = "Set cwd" }
          )
          vim.keymap.set("n", "go", ui_open, { buffer = args.data.buf_id, desc = "OS open" })
          vim.keymap.set("n", "gy", yank_path, { buffer = args.data.buf_id, desc = "Yank path" })
        end,
      })
    end,
  },
  {
    "echasnovski/mini.hipatterns",
    opts = {
      -- Delays (in ms) defining asynchronous highlighting process
      delay = {
        text_change = 100,
        scroll = 50,
      },
      highlighters = {
        -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

        hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),

        -- test colors
        fail = {
          pattern = function()
            return vim.bo.filetype == "quicktest-output" and "%f[%w]()FAIL()%f[%W]" or nil
          end,
          group = require("mini.hipatterns").compute_hex_color_group("#B4635A", "fg"),
        },
        pass = {
          pattern = function()
            return vim.bo.filetype == "quicktest-output" and "%f[%w]()PASS()%f[%W]" or nil
          end,
          group = require("mini.hipatterns").compute_hex_color_group("#6E8B56", "fg"),
        },
        ok = {
          pattern = function()
            return vim.bo.filetype == "quicktest-output" and "%f[%w]()ok()%f[%W]" or nil
          end,
          group = require("mini.hipatterns").compute_hex_color_group("#6E8B56", "fg"),
        },
      },
    },
  },
  { "echasnovski/mini.icons" },
  {
    "echasnovski/mini.diff",
    event = "VeryLazy",
    keys = {
      {
        "<leader>go",
        function()
          require("mini.diff").toggle_overlay(0)
        end,
        desc = "Toggle mini.diff overlay",
      },
    },
    opts = {
      view = {
        style = "sign",
        signs = {
          add = "▎",
          change = "▎",
          delete = "",
        },
      },
    },
  },
  {
    "mini.diff",
    opts = function()
      Snacks.toggle({
        name = "Mini Diff Signs",
        get = function()
          return vim.g.minidiff_disable ~= true
        end,
        set = function(state)
          vim.g.minidiff_disable = not state
          if state then
            require("mini.diff").enable(0)
          else
            require("mini.diff").disable(0)
          end
          -- HACK: redraw to update the signs
          vim.defer_fn(function()
            vim.cmd([[redraw!]])
          end, 200)
        end,
      }):map("<leader>uG")
    end,
  },
}
