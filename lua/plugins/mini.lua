local mini_float
return {
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

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesExplorerClose",
        callback = function(args)
          if mini_float ~= nil then
            mini_float:close()
            mini_float = nil
          end
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          if mini_float ~= nil then
            mini_float:destroy()
            mini_float = nil
          end

          local bufname = vim.api.nvim_buf_get_name(args.buf)
          if bufname == nil then
            return
          end

          if bufname:match("^minifiles://") then
            bufname = bufname:gsub("^minifiles://[0-9]+//", "/")
          end

          -- Inside the autocmd callback
          local win_id = vim.fn.bufwinid(args.buf)
          if win_id <= 0 then
            return
          end

          -- Get cursor line in the preview buffer
          local cursor_line = vim.api.nvim_win_get_cursor(win_id)[1]
          local lines = vim.api.nvim_buf_get_lines(args.buf, cursor_line - 1, cursor_line, false)
          local filename = lines[1]
          local last_part = vim.fn.fnamemodify(filename, ":t")

          if last_part == nil then
            return
          end

          local full_path = bufname .. "/" .. last_part

          if Snacks.image.supports(full_path) then
            mini_float = Snacks.win({
              width = 0.5,
              height = 0.9,
              border = "single",
              relative = "editor",
              row = 0,
              col = 0.5,
              title = last_part,
            })
            vim.schedule(function()
              local ok, err = pcall(function()
                Snacks.image.placement.new(mini_float.buf, full_path, {
                  max_width = mini_float.opts.max_width,
                  max_height = mini_float.opts.max_height,
                })
              end)
              if not ok then
                vim.notify("Failed to load image: " .. err, vim.log.levels.WARN)
              end
            end)
          end
        end,
      })

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

      local show_in_finder = function()
        vim.fn.system({ "open", "-R", MiniFiles.get_fs_entry().path })
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
          vim.keymap.set("n", "gf", show_in_finder, { buffer = args.data.buf_id, desc = "Show in finder" })
          vim.keymap.set("n", "gy", yank_path, { buffer = args.data.buf_id, desc = "Yank path" })
        end,
      })
    end,
  },
  {
    "nvim-mini/mini.hipatterns",
    opts = {
      delay = {
        text_change = 100,
        scroll = 50,
      },
      highlighters = {
        hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
      },
    },
  },
}
