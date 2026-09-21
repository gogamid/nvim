return {
  {
    "nvim-mini/mini.nvim",
    lazy = false,
    version = false,
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = "Open mini.files (Directory of Current File)",
      },
    },
    config = function()
      local hipatterns = require("mini.hipatterns")
      hipatterns.setup({
        highlighters = {
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      })

      require("mini.icons").setup({
        style = vim.g.icons_enabled and "glyph" or "ascii",
      })

      local filter_hide = function(fs_entry)
        return not vim.startswith(fs_entry.name, ".")
      end

      require("mini.files").setup({
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
          synchronize = "w",
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
      })

      local show_dotfiles = false
      local filter_show = function(fs_entry)
        return true
      end

      local toggle_hidden = function()
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

      -- Yank path relative to current working directory (root)
      local yank_relative_path = function()
        local entry = MiniFiles.get_fs_entry()
        if entry == nil then
          return vim.notify("Cursor is not on valid entry")
        end
        local relpath = vim.fn.fnamemodify(entry.path, ":.")
        vim.fn.setreg(vim.v.register, relpath)
      end

      -- Open path with system default handler (useful for non-text files)
      local os_open = function()
        vim.ui.open(MiniFiles.get_fs_entry().path)
      end

      local show_in_finder = function()
        vim.fn.system({ "open", "-R", MiniFiles.get_fs_entry().path })
      end

      -- Sort toggles: first press sorts ascending, pressing the same key flips it
      local sort_fields = {
        sn = { field = "lower_name", label = "name" },
        sm = { field = "mtime", label = "modified" },
        sz = { field = "size", label = "size" },
        sk = { field = "kind", label = "kind" },
      }
      local sort_field, sort_desc = "lower_name", false

      local sort_by_field = function(fs_entries)
        local uv = vim.uv or vim.loop
        local entries = {}
        for _, entry in ipairs(fs_entries) do
          local stat = uv.fs_stat(entry.path)
          entries[#entries + 1] = {
            name = entry.name,
            path = entry.path,
            fs_type = entry.fs_type,
            is_dir = entry.fs_type == "directory",
            lower_name = entry.name:lower(),
            mtime = stat and (stat.mtime.sec + stat.mtime.nsec * 1e-9) or 0,
            size = stat and stat.size or 0,
            kind = vim.fn.fnamemodify(entry.name, ":e"):lower(),
          }
        end

        table.sort(entries, function(a, b)
          -- drop this branch to sort files and directories together
          if a.is_dir ~= b.is_dir then
            return a.is_dir
          end
          local va, vb = a[sort_field], b[sort_field]
          if va ~= vb then
            if sort_desc then
              return va > vb
            end
            return va < vb
          end
          return a.lower_name < b.lower_name
        end)

        return vim.tbl_map(function(entry)
          return { name = entry.name, fs_type = entry.fs_type, path = entry.path }
        end, entries)
      end

      local toggle_sort = function(key)
        local cfg = sort_fields[key]
        if sort_field ~= cfg.field then
          sort_field, sort_desc = cfg.field, false
        else
          sort_desc = not sort_desc
        end
        require("mini.files").refresh({ content = { sort = sort_by_field } })
        vim.notify("mini.files: sort by " .. cfg.label .. ", " .. (sort_desc and "descending" or "ascending"))
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf = args.data.buf_id
          vim.keymap.set("n", "g.", toggle_hidden, { buffer = buf, desc = "Toggle hidden files" })
          vim.keymap.set("n", "go", os_open, { buffer = buf, desc = "OS open" })
          vim.keymap.set("n", "gf", show_in_finder, { buffer = buf, desc = "Show in finder" })
          vim.keymap.set("n", "gp", yank_relative_path, { buffer = buf, desc = "Yank relative path" })
          vim.keymap.set("n", "gy", yank_path, { buffer = buf, desc = "Yank absolute path" })
          for key, cfg in pairs(sort_fields) do
            vim.keymap.set("n", key, function()
              toggle_sort(key)
            end, {
              buffer = buf,
              desc = "Sort by " .. cfg.label .. " (toggle asc/desc)",
            })
          end
        end,
      })
    end,
  },
}
