return {
  {
    "mason-org/mason.nvim",
    opts = {
      log_level = vim.log.levels.DEBUG,
      install_root_dir = os.getenv("HOME") .. "/.local/bin/",
      ensure_installed = {
      },
    },
    keys = {
      {"<leader>M", "<cmd>Mason<cr>", desc = "Mason Menu"},
    },
    config = function(_, opts)
      require("mason").setup(opts)
      -- vim.cmd[[MasonInstall buf bash-language-server gofumpt goimports gopls json-lsp lua-language-server prettier shfmt sqlls sqls stylua taplo vtsls vue-language-server yaml-language-server yamlfmt]]
    end,
  }
}
