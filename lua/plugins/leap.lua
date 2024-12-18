return {
  {
    "ggandor/leap.nvim",
    keys = {
      {
        "s",
        function()
          require("leap").leap({})
        end,
        mode = { "n", "x", "o" },
        desc = "Leap Forward to",
      },
      {
        "S",
        function()
          require("leap").leap({ backward = true })
        end,
        mode = { "n", "x", "o" },
        desc = "Leap Backward to",
      },
      { "gs", mode = { "n", "x", "o" }, desc = "Leap from Windows" },
    },
    config = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "LeapEnter",
        callback = function()
          vim.api.nvim_create_autocmd("CursorMoved", {
            once = true,
            callback = function()
              vim.cmd("normal! zz")
            end,
          })
        end,
      })
    end,
  },
}
