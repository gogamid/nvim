---@param background? "dark" | "light
---@param contrast? "hard" | "medium" | "soft"
local function everforest(background, contrast)
  if not background then
    background = "dark"
  end
  if not contrast then
    contrast = "soft"
  end

  vim.cmd("set background=" .. background)
  vim.cmd(string.format("let g:everforest_background='%s'", contrast))
  vim.cmd([[
    let g:everforest_enable_italic = 1
    let g:everforest_disable_italic_comment = 1

    colorscheme everforest
  ]])
end

return {
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        -- vim.cmd("colorscheme catppuccin-frappe")
        --
        everforest("dark", "hard")

        vim.cmd("highlight Normal guibg=none")
        vim.cmd("highlight NormalNC guibg=none")
        vim.cmd("highlight NormalSB guibg=none")
        vim.cmd("highlight NormalFloat guibg=none")
        vim.cmd("highlight Pmenu guibg=none")
        vim.cmd("highlight FloatBorder guibg=none")
        vim.cmd("highlight NonText guibg=none")
        vim.cmd("highlight Normal ctermbg=none")
        vim.cmd("highlight NonText ctermbg=none")
        vim.cmd("highlight EndOfBuffer guibg=none ctermbg=none")

        vim.api.nvim_set_hl(0, "LspCodeLens", { link = "Conceal" })
        vim.api.nvim_set_hl(0, "LspCodeLensSeparator", { link = "Conceal" })
      end,
      set_light_mode = function()
        -- vim.cmd("colorscheme catppuccin-latte")
        everforest("light", "medium")

        vim.api.nvim_set_hl(0, "Visual", { bg = "#A7C080", fg = "#2B3339" })
      end,
    },
  },
  {
    "sainnhe/everforest",
    -- lazy = false, -- make sure we load this during startup if it is your main colorscheme
    -- priority = 1000, -- make sure to load this before all the other start plugins
    -- config = function()
    --   -- load the colorscheme here
    --   vim.cmd([[colorscheme everforest]])
    -- end,
  },
}
