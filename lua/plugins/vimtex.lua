return {
  "lervag/vimtex",
  enabled = false, --not writing latex anymore
  config = function()
    -- vim.g.vimtex_compiler_latexmk_engines = "lualatex"
    vim.g.vimtex_view_method = "sioyek"
    vim.g.vimtex_view_sioyek_options = "--reuse-window"
    vim.opt.wrap = true
    vim.opt.linebreak = true
  end,
}
