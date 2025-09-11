return {
  "mason-org/mason.nvim",
  opts = {
    --manual installs via :Mason
    ensure_installed = {},
  },
  keys = {
    {"<leader>M", ":Mason<CR>", desc = "Mason"},
  },
}
