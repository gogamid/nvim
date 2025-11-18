local function augroup(name)
  return vim.api.nvim_create_augroup("ig_" .. name, { clear = true })
end

-- ---@param filetype? string
-- local function checkForTreesitter(filetype)
--   if vim.o.diff then
--     return
--   end
--
--   if not filetype then
--     filetype = vim.bo.filetype
--   end
--   local win = vim.api.nvim_get_current_win()
--
--   local ok, hasParser = pcall(vim.treesitter.query.get, filetype, "folds")
--
--   if ok and hasParser then
--     vim.wo[win][0].foldmethod = "expr"
--     vim.wo[win][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
--   else
--     vim.wo[win][0].foldexpr = ""
--     vim.wo[win][0].foldtext = "v:lua.custom_foldtext()"
--   end
-- end
--
-- vim.api.nvim_create_autocmd("FileType", {
--   desc = "Enable treesitter folding else fallback to indent folding",
--   group = augroup("folding"),
--   callback = function(ctx)
--     checkForTreesitter(ctx.match)
--   end,
-- })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "Return to last edit position when opening files",
  group = augroup("return_to_last_edit_position"),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  desc = "Auto resize splits when window is resized",
  group = augroup("auto_resize"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  desc = "Create directories when saving files",
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Wrap text for text filetypes",
  group = augroup("wrap_text_filetypes"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.relativenumber = false
    vim.opt_local.number = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Close file with <q>",
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "checkhealth",
    "dbout",
    "gitsigns-blame",
    "grug-far",
    "help",
    "lspinfo",
    "neotest-output",
    "neotest-output-panel",
    "neotest-summary",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>close<CR>", {
      buffer = args.buf,
      silent = true,
      desc = "Quit terminal window",
    })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Add pb import aliases on nexus repo",
  group = augroup("add_pb_import_aliases"),
  callback = function()
    if vim.fn.getcwd():find(vim.fn.expand("$NEXUS_REPO"), 1, true) == 1 then
      require("modules.pb_snips").compute_and_add_alias_import_snippets()
    end
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  desc = "Reload file when it changed outside of vim",
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  desc = "Set conceallevel to 0 for json files",
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("setup_auto_root", {}),
  callback = function(data)
    vim.o.autochdir = false
    local root = vim.fs.root(data.buf, { "service.yaml", ".git" })
    if root == nil or root == vim.fn.getcwd() then
      return
    end
    vim.fn.chdir(root)
    vim.api.nvim_echo({ { "chdir to " .. root, "WarningMsg" } }, true, {})
  end,
  desc = "Find root and change current directory",
  -- once = true,
})
