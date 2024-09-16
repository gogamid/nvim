local icons = LazyVim.config.icons
return {
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          "%=", -- center
          { "filename", path = 1 },
          { "filetype", component_separators = { left = "|", right = "|" } },
          {
            function()
              local lsps = vim.lsp.get_clients({ bufnr = vim.fn.bufnr() })
              if lsps and #lsps > 0 then
                local names = {}
                for _, lsp in ipairs(lsps) do
                  table.insert(names, lsp.name)
                end
                return table.concat(names, ", ")
              else
                return ""
              end
            end,
            on_click = function()
              vim.api.nvim_command("LspInfo")
            end,
          },
        },
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 2, {
        function()
          local output = string.find(require("tabnine.status").status(), "disabled") and ""
            or LazyVim.config.icons.kinds.TabNine
          return output
        end,
      })
    end,
  },
}
