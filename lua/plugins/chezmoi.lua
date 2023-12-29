return {
  {
    'xvzc/chezmoi.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { "<leader>cz", function() require("telescope").extensions.chezmoi.find_files() end, desc = "find chezmoi files", },
    },
    config = function()
      require("chezmoi").setup {
        edit = {
          watch = true,
          force = true,
        },
        notification = {
          on_open = true,
          on_apply = true,
        },
      }
    end
  },
  -- syntax highlighting for chezmoi files
  {'alker0/chezmoi.vim'}
}
