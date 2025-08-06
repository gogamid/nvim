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

      --vue
      "vue-language-server",
      "vtsls",

      --shell
      "shfmt",

      --markdown
      "prettier",

      --json
      "json-lsp",

      --toml
      "taplo",
    },
  },
}
