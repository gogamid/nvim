return {
  "mason-org/mason.nvim",
  opts = {
    ensure_installed = {
      --go
      "gopls",
      "goimports",
      "gofumpt",

      --proto
      "buf",

      --lua
      "stylua",

      --toml
      "taplo",
    },
  },
}
