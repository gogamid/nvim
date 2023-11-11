***REMOVED***
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      opts.on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc ***REMOVED***)
    ***REMOVED***
        -- stylua: ignore start
        map("n", "]h",
        function()
          require("gitsigns").next_hunk()
          vim.cmd("normal! zz")
    ***REMOVED***, "Next Hunk")

        map("n", "[h",
        function()
          require("gitsigns").prev_hunk()
          vim.cmd("normal! zz")
    ***REMOVED***, "Prev Hunk")

        map({ "n", "v" ***REMOVED***, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" ***REMOVED***, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true ***REMOVED***) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" ***REMOVED***, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
  ***REMOVED***
***REMOVED***,
***REMOVED***
***REMOVED***
