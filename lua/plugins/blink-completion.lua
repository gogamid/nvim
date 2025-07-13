return {
  "saghen/blink.cmp",
  dependencies = {
    { "archie-judd/blink-cmp-words" },
    {
      "edte/blink-go-import.nvim",
      ft = "go",
      config = function()
        require("blink-go-import").setup()
      end,
    },
  },
  opts = {
    sources = {
      providers = {
        thesaurus = {
          name = "blink-cmp-words",
          module = "blink-cmp-words.thesaurus",
          -- All available options
          opts = {
            -- A score offset applied to returned items.
            -- By default the highest score is 0 (item 1 has a score of -1, item 2 of -2 etc..).
            score_offset = 0,

            -- Default pointers define the lexical relations listed under each definition,
            -- see Pointer Symbols below.
            -- Default is as below ("antonyms", "similar to" and "also see").
            pointer_symbols = { "!", "&", "^" },
          },
        },
        dictionary = {
          name = "blink-cmp-words",
          module = "blink-cmp-words.dictionary",
          -- All available options
          opts = {
            -- The number of characters required to trigger completion.
            -- Set this higher if completion is slow, 3 is default.
            dictionary_search_threshold = 3,

            -- See above
            score_offset = 0,

            -- See above
            pointer_symbols = { "!", "&", "^" },
          },
        },
        go_pkgs = {
          module = "blink-go-import",
          name = "Import",
        },
      },
      per_filetype = {
        markdown = { "dictionary" },
      },
    },
  },
}
