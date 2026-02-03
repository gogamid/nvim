-------------------------------------------------- CORE --------------------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.autoindent = true

vim.opt.clipboard = "unnamedplus"

-------------------------------------------------- QOL --------------------------------------------------------------------------------
vim.opt.scrolloff = 10 -- Keep 10 lines above/below cursor

vim.o.breakindent = true -- Indent wrapped lines to match line start
vim.o.linebreak = true -- Wrap lines at 'breakat' (if 'wrap' is set)

vim.o.splitbelow = true -- Horizontal splits will be below
vim.o.splitright = true -- Vertical splits will be to the right

vim.o.foldmethod = "indent" -- Fold based on indent level
vim.opt.foldlevel = 99 -- Do not fold by default

vim.o.ignorecase = true -- Ignore case during search
vim.o.smartcase = true -- Respect case if search pattern has upper case

vim.opt.autoread = true -- Auto reload files changed outside vim
vim.opt.autochdir = true

vim.o.confirm = true

vim.o.winborder = "single"

vim.opt.fillchars = {
  eob = " ",
  diff = "╱",
  foldopen = "",
  foldclose = "",
  foldsep = "▕",
}

vim.diagnostic.config({
  virtual_text = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅚 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "ErrorMsg",
      [vim.diagnostic.severity.WARN] = "WarningMsg",
    },
  },
})

------------------------------------------------- CUSTOM -------------------------------------------------------------------------------
vim.g.icons_enabled = true

if vim.g.neovide then
  vim.g.transparency = 0.8
  vim.g.neovide_opacity = 0.2
  vim.g.neovide_normal_opacity = 0.6
  vim.g.neovide_show_border = false
  vim.g.neovide_background_color = "#2A3035"
end

vim.filetype.add({
  extension = {
    apt = "gupta",
  },
  pattern = {
    [".*%.apt%.indented"] = "gupta",
  },
})

------------------------------------------------- BACKUP -------------------------------------------------------------------------------
-- -- stylua: ignore start
-- vim.o.mouse           = 'a'                    -- Enable mouse
-- -- vim.o.mousescroll     = 'ver:25,hor:6'         -- Customize mouse scroll
-- vim.o.switchbuf       = 'usetab'               -- Use already opened buffers when switching
-- vim.o.undofile        = true                   -- Enable persistent undo
--
-- vim.o.shada = "'100,<50,s10,:1000,/100,@100,h" -- Limit ShaDa file (for startup)
--
-- -- UI =========================================================================
-- vim.opt.sidescrolloff = 8 -- Keep 8 columns left/right of cursor
-- vim.o.breakindentopt = 'list:-1'  -- Add padding for lists (if 'wrap' is set)
-- vim.o.linebreak      = true       -- Wrap lines at 'breakat' (if 'wrap' is set)
-- vim.o.list           = true       -- Show helpful text indicators
-- vim.o.pumheight      = 10         -- Make popup menu smaller
-- vim.o.ruler          = false      -- Don't show cursor coordinates
-- vim.o.shortmess      = 'CFOSWaco' -- Disable some built-in completion messages
-- vim.o.showmode       = false      -- Don't show mode in command line
-- vim.o.signcolumn     = 'yes'      -- Always show signcolumn (less flicker)
-- vim.o.splitkeep      = 'screen'   -- Reduce scroll during window split
-- vim.o.wrap           = false      -- Don't visually wrap lines
-- vim.o.termguicolors  = true       -- Enable 24-bit colors
-- vim.o.cmdheight      = 1          -- Command line height
-- vim.o.pumblend       = 10         -- Popup menu transparency
-- vim.o.winblend       = 0          -- Floating window transparency
-- vim.o.conceallevel   = 2          -- replace conceal  switch with 🎮
-- vim.o.concealcursor  = ""         -- Don't hide cursor line markup
-- vim.o.lazyredraw     = true       -- Don't redraw during macros
--
-- vim.opt.showtabline = 1 -- Always show tabline (0=never, 1=when multiple tabs, 2=always)
-- vim.opt.tabline = "" -- Use default tabline (empty string uses built-in)
--
-- vim.o.cursorlineopt  = 'screenline,number' -- Show cursor line per screen line
--
-- -- Special UI symbols.
-- vim.opt.listchars = {
--   extends = "…",
--   nbsp = "␣",
--   precedes = "…",
--   tab = "> ",
-- }
--
-- -- Folds (see `:h fold-commands`, `:h zM`, `:h zR`, `:h zA`, `:h zj`)
-- function _G.custom_foldtext()
--   local start_line = vim.fn.getline(vim.v.foldstart)
--   local next_line = vim.fn.getline(vim.v.foldstart + 1)
--   local line_count = vim.v.foldend - vim.v.foldstart + 1
--   local indent = string.rep(" ", vim.fn.indent(vim.v.foldstart))
--
--   -- Combine two lines and limit to 80 chars
--   local combined = vim.trim(start_line) .. " " .. vim.trim(next_line)
--   if #combined > 80 then
--     combined = combined:sub(1, 60)
--   end
--
--   return string.format("%s%s ... (%d lines)", indent, combined, line_count)
-- end
--
-- vim.o.foldlevel   = 10       -- Fold nothing by default; set to 0 or 1 to fold
-- vim.o.foldnestmax = 10       -- Limit number of fold levels
-- vim.opt.foldtext = "v:lua.custom_foldtext()"
--
-- -- Editing ====================================================================
-- vim.o.expandtab     = true    -- Convert tabs to spaces
-- vim.o.formatoptions = 'rqnl1j'-- Improve comment editing
-- vim.o.infercase     = true    -- Infer case in built-in completion
-- vim.o.smartindent   = true    -- Make indenting smart
-- vim.o.spelloptions  = 'camel' -- Treat camelCase word parts as separate words
-- vim.o.virtualedit   = 'block' -- Allow going past end of line in blockwise mode
--
-- vim.o.iskeyword = '@,48-57,_,192-255,-' -- Treat dash as `word` textobject part
--
-- -- Pattern for a start of numbered list (used in `gw`). This reads as
-- -- "Start of list item is: at least one special character (digit, -, +, *)
-- -- possibly followed by punctuation (. or `)`) followed by at least one space".
-- vim.o.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]
--
-- -- Built-in completion
-- vim.o.complete    = '.,w,b,kspell'                  -- Use less sources
-- vim.o.completeopt = 'menuone,noselect,fuzzy,nosort' -- Use custom behavior
--
-- -- File handling
-- vim.opt.backup = false -- Don't create backup files
-- vim.opt.writebackup = false -- Don't create backup before writing
-- vim.opt.swapfile = false -- Don't create swap files
--
--
-- -- Behavior settings
-- vim.opt.hidden = true -- Allow hidden buffers
-- vim.opt.errorbells = false -- No error bells
-- vim.opt.backspace = "indent,eol,start" -- Better backspace behavior
-- vim.opt.path:append("**") -- include subdirectories in search
-- vim.opt.selection = "exclusive" -- Selection behavior
-- vim.opt.encoding = "UTF-8" -- Set encoding
--
-- -- Command-line completion
-- vim.opt.wildmenu = true
-- vim.opt.wildmode = "longest:full,full"
-- vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })
--
-- -- Better diff options
-- vim.opt.diffopt:append("linematch:60")
--
-- -- Performance improvements
-- vim.opt.redrawtime = 10000
-- vim.opt.maxmempattern = 20000
-- vim.opt.updatetime = 300 -- Faster completion
-- vim.opt.timeoutlen = 500 -- Key timeout duration
-- vim.opt.ttimeoutlen = 0 -- Key code timeout
-- vim.opt.synmaxcol = 300 -- Syntax highlighting limit
--
-- -- Transparent tabline appearance
-- vim.cmd([[
--   hi TabLineFill guibg=NONE ctermfg=242 ctermbg=NONE
-- ]])
--
--
