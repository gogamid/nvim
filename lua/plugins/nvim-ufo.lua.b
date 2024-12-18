return {
  { -- QoL features for folding
    "chrisgrieser/nvim-origami",
    event = "VeryLazy",
    opts = true,
  },
  { -- use LSP as folding provider
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    event = "UIEnter", -- needed for folds to load in time and comments being closed
    keys = {
      { "z?", vim.cmd.UfoInspect, desc = "󱃄 :UfoInspect" },
      {
        "zm",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "󱃄 Close All Folds",
      },
      {
        "zr",
        function()
          require("ufo").openFoldsExceptKinds({ "comment", "imports" })
        end,
        desc = "󱃄 Open Regular Folds",
      },
      {
        "z1",
        function()
          require("ufo").closeFoldsWith(1)
        end,
        desc = "󱃄 Close L1 Folds",
      },
      {
        "z2",
        function()
          require("ufo").closeFoldsWith(2)
        end,
        desc = "󱃄 Close L2 Folds",
      },
      {
        "z3",
        function()
          require("ufo").closeFoldsWith(3)
        end,
        desc = "󱃄 Close L3 Folds",
      },
    },
    init = function()
      -- INFO fold commands usually change the foldlevel, which fixes folds, e.g.
      -- auto-closing them after leaving insert mode, however ufo does not seem to
      -- have equivalents for zr and zm because there is no saved fold level.
      -- Consequently, the vim-internal fold levels need to be disabled by setting
      -- them to 99.
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
    end,
    opts = {
      -- when opening the buffer, close these fold kinds
      close_fold_kinds_for_ft = {
        default = { "imports", "comment" },
        json = { "array" },
        -- use `:UfoInspect` to get see available fold kinds
      },
      open_fold_hl_timeout = 800,

      provider_selector = function(bufnr, filetype, buftype)
        local ftMap = {
          vim = "indent",
          python = { "indent" },
          git = "",
        }

        local function customizeSelector(bufnr)
          local function handleFallbackException(err, providerName)
            if type(err) == "string" and err:match("UfoFallbackException") then
              return require("ufo").getFolds(providerName, bufnr)
            else
              return require("promise").reject(err)
            end
          end

          return require("ufo")
            .getFolds("lsp", bufnr)
            :catch(function(err)
              return handleFallbackException(err, "treesitter")
            end)
            :catch(function(err)
              return handleFallbackException(err, "indent")
            end)
        end

        return ftMap[filetype] or customizeSelector
      end,

      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local hlgroup = "NonText"
        local icon = ""
        local newVirtText = {}
        local suffix = ("  %s %d"):format(icon, endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, hlgroup })
        return newVirtText
      end,
    },
  },
}
