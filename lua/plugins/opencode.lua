return {
  "NickvanDyke/opencode.nvim",
  enabled = false,
  dependencies = {
    "folke/snacks.nvim",
  },
  ---@type opencode.Config
  opts = {
    -- Your configuration, if any
  },
  -- stylua: ignore
  keys = {
    -- opencode.nvim exposes a general, flexible API — customize it to your workflow!
    -- But here are some examples to get you started :)
    { '<leader>at', function() require('opencode').toggle() end, desc = 'Toggle opencode', },
    { '<leader>ak', function() require('opencode').ask() end, desc = 'Ask opencode', mode = { 'n', 'v' }, },
    { '<leader>aK', function() require('opencode').ask('@file ') end, desc = 'Ask opencode about current file', mode = { 'n', 'v' }, },
    { '<leader>an', function() require('opencode').command('/new') end, desc = 'New session', },
    { '<leader>ae', function() require('opencode').prompt('Explain @cursor and its context') end, desc = 'Explain code near cursor' },
    { '<leader>ar', function() require('opencode').prompt('Review @file for correctness and readability') end, desc = 'Review file', },
    { '<leader>af', function() require('opencode').prompt('Fix these @diagnostics') end, desc = 'Fix errors', },
    { '<leader>ao', function() require('opencode').prompt('Optimize @selection for performance and readability') end, desc = 'Optimize selection', mode = 'v', },
    { '<leader>ad', function() require('opencode').prompt('Add documentation comments for @selection') end, desc = 'Document selection', mode = 'v', },
    { '<leader>at', function() require('opencode').prompt('Add tests for @selection') end, desc = 'Test selection', mode = 'v', },
  },
}
