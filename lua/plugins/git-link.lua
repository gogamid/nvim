return {
  "juacker/git-link.nvim",
  keys = {
    {
      "<leader>gy",
      function()
        require("git-link.main").copy_line_url()
      end,
      desc = "Copy code link to clipboard",
      mode = { "n", "x" },
    },
    {
      "<leader>gO",
      function()
        require("git-link.main").open_line_url()
      end,
      desc = "Open code link in browser",
      mode = { "n", "x" },
    },
  },

  config = function(_, opts)
    opts.url_rules = {
      -- Handles Azure Repos SSH URLs
      pattern = "^git@ssh%.dev%.azure%.com:v3/([^/]+)/([^/]+)/([^/]+)$",
      replace = "https://dev.azure.com/%1/%2/_git/%3",
      format_url = function(base_url, params)
        print("Base URL: ", base_url)
        print("Params: ", vim.inspect(params))

        local single_line_url = string.format(
          "%s?path=/%s&version=GB%s&line=%d&lineEnd=%d&lineStartColumn=1&lineEndColumn=%d&lineStyle=plain&_a=contents",
          base_url,
          params.file_path,
          params.branch,
          params.start_line,
          params.end_line,
          params.end_column or 1
        )

        print("Single Line URL: ", single_line_url)

        if params.start_line == params.end_line then
          return single_line_url
        end

        local multi_line_url = string.format("%s&lineEndColumn=%d", single_line_url, params.end_column or 1)
        print("Multi Line URL: ", multi_line_url)

        return multi_line_url
      end,
    }
  end,
}
