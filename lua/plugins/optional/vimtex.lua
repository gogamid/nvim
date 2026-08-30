return {
  "lervag/vimtex",
  enabled = true,
  config = function()
    vim.g.vimtex_compiler_method = "tectonic"
    vim.g.vimtex_view_method = "sioyek"
    vim.g.vimtex_view_sioyek_options = "--reuse-window"
  end,
}
