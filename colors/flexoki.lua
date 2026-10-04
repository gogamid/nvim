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
local surfaces = bg == "light"
    and { cursor = "#6F6E69", cursor_line = "#F2F0E5", code = "#F8F5EB" }
  or { cursor = "#878580", cursor_line = "#1C1B1A", code = "#161514" }
local specs = lush.extends({ base_specs }).with(function()
  return {
    String({ base_specs.String, fg = stringColor }),
    Cursor({ base_specs.Cursor, bg = surfaces.cursor }),
    CursorLine({ bg = surfaces.cursor_line }),
    CursorColumn({ bg = surfaces.cursor_line }),
    RenderMarkdownCode({ bg = surfaces.code }),
    RenderMarkdownCodeInline({ bg = surfaces.code }),
    SnacksPicker({ bg = "NONE" }),
    NormalFloat({ bg = "NONE" }),
    FloatBorder({ base_specs.FloatBorder, bg = "NONE" }),
    DebugPrintLine({ base_specs.DiagnosticHint, bg = "NONE" }),
  }
end)

lush(specs)

-- Set terminal colors (if used).
require("zenbones.term").apply_colors(palette)
