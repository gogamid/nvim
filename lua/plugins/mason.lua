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

      --vue
      "vue-language-server",
      "vtsls",

      --shell
      "shfmt",

      --markdown
      "prettier",

      --xml
      "xmlformatter",
    },
  },
}
