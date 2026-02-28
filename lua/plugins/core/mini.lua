local filter_hide = function(fs_entry)
  return not vim.startswith(fs_entry.name, ".")
end
return {
  {
    "nvim-mini/mini.nvim",
    version = false,
    config = function()
      local hipatterns = require("mini.hipatterns")
      hipatterns.setup({
        highlighters = {
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      })

      require("mini.surround").setup()

      require("mini.icons").setup({
        style = vim.g.icons_enabled and "glyph" or "ascii",
      })
    end,
  },
  {
    "nvim-mini/mini.files",
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
      content = {
        filter = filter_hide,
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

      local show_dotfiles = false
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

      local untar = function()
        local entry = MiniFiles.get_fs_entry()
        if entry == nil then
          return
        end
        local path = entry.path
        if vim.fn.executable("tar") == 1 then
          local path_dir = vim.fn.fnamemodify(path, ":h")
          vim.fn.system({ "tar", "-xf", path, "-C", path_dir })
          vim.notify("Untarred " .. path)
          require("mini.files").refresh()
        end
      end

      local show_in_finder = function()
        vim.fn.system({ "open", "-R", MiniFiles.get_fs_entry().path })
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf = args.data.buf_id

          vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf, desc = "Toggle hidden files" })
          vim.keymap.set("n", "go", ui_open, { buffer = buf, desc = "OS open" })
          vim.keymap.set("n", "gf", show_in_finder, { buffer = buf, desc = "Show in finder" })
          vim.keymap.set("n", "gy", yank_path, { buffer = buf, desc = "Yank path" })
          vim.keymap.set("n", "<C-x>", untar, { buffer = buf, desc = "Untar" })
        end,
      })
    end,
  },
}
