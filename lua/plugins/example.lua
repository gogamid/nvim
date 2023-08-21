-- since this is just an example spec, don't actually load anything here and return an empty spec
-- stylua: ignore
if true then ***REMOVED******REMOVED*** end

-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
***REMOVED***
  -- add gruvbox
  { "ellisonleao/gruvbox.nvim" ***REMOVED***,

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
  ***REMOVED***
***REMOVED***

  -- change trouble config
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true ***REMOVED***,
***REMOVED***

  -- disable trouble
  { "folke/trouble.nvim", enabled = false ***REMOVED***,

  -- add symbols-outline
  {
    "simrat39/symbols-outline.nvim",
    cmd = "SymbolsOutline",
  ***REMOVED*** { "<leader>cs", "<cmd>SymbolsOutline<cr>", desc = "Symbols Outline" ***REMOVED*** ***REMOVED***,
    config = true,
***REMOVED***

  -- override nvim-cmp and add cmp-emoji
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" ***REMOVED***,
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "emoji" ***REMOVED*** ***REMOVED***))
***REMOVED***,
***REMOVED***

  -- change some telescope options and a keymap to browse plugin files
  {
    "nvim-telescope/telescope.nvim",
  ***REMOVED***
      -- add a keymap to browse plugin files
      -- stylua: ignore
***REMOVED***
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root ***REMOVED***) end,
        desc = "Find Plugin File",
    ***REMOVED***
  ***REMOVED***
    -- change some options
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" ***REMOVED***,
        sorting_strategy = "ascending",
        winblend = 0,
    ***REMOVED***
  ***REMOVED***
***REMOVED***

  -- add telescope-fzf-native
  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    ***REMOVED***
        require("telescope").load_extension("fzf")
  ***REMOVED***,
  ***REMOVED***
***REMOVED***

  -- add pyright to lspconfig
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- pyright will be automatically installed with mason and loaded with lspconfig
        pyright = {***REMOVED***,
    ***REMOVED***
  ***REMOVED***
***REMOVED***

  -- add tsserver and setup with typescript.nvim instead of lspconfig
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "jose-elias-alvarez/typescript.nvim",
      init = function()
        require("lazyvim.util").on_attach(function(_, buffer)
          -- stylua: ignore
          vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" ***REMOVED***)
          vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer ***REMOVED***)
    ***REMOVED***)
  ***REMOVED***,
  ***REMOVED***
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        -- tsserver will be automatically installed with mason and loaded with lspconfig
        tsserver = {***REMOVED***,
    ***REMOVED***
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {
        -- example to setup with typescript.nvim
        tsserver = function(_, opts)
          require("typescript").setup({ server = opts ***REMOVED***)
          return true
    ***REMOVED***,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
    ***REMOVED***
  ***REMOVED***
***REMOVED***

  -- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
  -- treesitter, mason and typescript.nvim. So instead of the above, you can use:
  { import = "lazyvim.plugins.extras.lang.typescript" ***REMOVED***,

  -- add more treesitter parsers
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "html",
        "javascript",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "tsx",
        "typescript",
        "vim",
        "yaml",
    ***REMOVED***
  ***REMOVED***
***REMOVED***

  -- since `vim.tbl_deep_extend`, can only merge tables and not lists, the code above
  -- would overwrite `ensure_installed` with the new value.
  -- If you'd rather extend the default config, use the code below instead:
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "tsx",
        "typescript",
  ***REMOVED***)
***REMOVED***,
***REMOVED***

  -- the opts function can also be used to change the default opts:
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, "😄")
***REMOVED***,
***REMOVED***

  -- or you can return new options to override all the defaults
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      ***REMOVED***
        --[[add your custom lualine config here]]
  ***REMOVED***
***REMOVED***,
***REMOVED***

  -- use mini.starter instead of alpha
  { import = "lazyvim.plugins.extras.ui.mini-starter" ***REMOVED***,

  -- add jsonls and schemastore packages, and setup treesitter for json, json5 and jsonc
  { import = "lazyvim.plugins.extras.lang.json" ***REMOVED***,

  -- add any tools you want to have installed below
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "stylua",
        "shellcheck",
        "shfmt",
        "flake8",
    ***REMOVED***
  ***REMOVED***
***REMOVED***

  -- Use <tab> for completion and snippets (supertab)
  -- first: disable default <tab> and <s-tab> behavior in LuaSnip
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      ***REMOVED******REMOVED***
***REMOVED***,
***REMOVED***
  -- then: setup supertab in cmp
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
  ***REMOVED***
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  ***REMOVED***

      local luasnip = require("luasnip")
      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
            -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
            -- this way you will only jump inside the snippet region
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
      ***REMOVED***
    ***REMOVED***, { "i", "s" ***REMOVED***),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
      ***REMOVED***
    ***REMOVED***, { "i", "s" ***REMOVED***),
  ***REMOVED***)
***REMOVED***,
***REMOVED***
***REMOVED***
