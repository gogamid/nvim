local colors_name = "flexoki"
vim.g.colors_name = colors_name -- Required when defining a colorscheme

local lush = require("lush")
local hsluv = lush.hsluv
local util = require("zenbones.util")

local bg = vim.o.background

-- Only `bg` is overridden; zenbones fills in its default accents.
local palette
if bg == "light" then
  palette = util.palette_extend({ bg = hsluv("#FFFCF0") }, bg) -- Flexoki paper
else
  palette = util.palette_extend({ bg = hsluv("#100F0F") }, bg) -- Flexoki black
end

-- Generate the full highlight set from the palette.
local generator = require("zenbones.specs")
local base_specs = generator.generate(palette, bg, generator.get_global_config(colors_name, bg))

local stringColor = vim.o.background == "light" and "#4F6C30" or "#819B69"
local specs = lush.extends({ base_specs }).with(function()
  return {
    String({ base_specs.String, fg = stringColor }),
    SnacksPicker({ bg = "NONE" }),
    NormalFloat({ bg = "NONE" }),
    FloatBorder({ base_specs.FloatBorder, bg = "NONE" }),
    DebugPrintLine({ base_specs.DiagnosticHint, bg = "NONE" }),
  }
end)

lush(specs)

-- Set terminal colors (if used).
require("zenbones.term").apply_colors(palette)
