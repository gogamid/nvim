local function set_btop_theme(name)
  local HOME = vim.fn.expand("$HOME")
  local btop_themes = HOME .. "/.config/btop/themes"
  local target = btop_themes .. "/" .. name .. ".theme"
  -- Nothing to do if the theme file is missing (avoids a dangling symlink).
  if vim.fn.filereadable(target) ~= 1 then
    return
  end
  local link = btop_themes .. "/current.theme"
  -- Async, ordered: repoint the symlink first, then reload btop so it never
  -- re-reads the old theme. Fire-and-forget; nothing waits on the result.
  local cmd = "ln -sfn "
    .. vim.fn.shellescape(target)
    .. " "
    .. vim.fn.shellescape(link)
    .. " && pkill -SIGUSR2 btop >/dev/null 2>&1"
  vim.system({ "sh", "-c", cmd })
end

local function set_wallpaper(mode)
  local CONFIG = vim.fn.stdpath("config")
  local BACKGROUNDS = CONFIG .. "/backgrounds"
  local wallpaper = BACKGROUNDS .. "/flexoki-" .. mode .. "-orb.png"
  vim.system({
    "osascript",
    "-e",
    'tell application "System Events" to tell every desktop to set picture to "' .. wallpaper .. '"',
  })
end

-- Apply a mode ("dark" or "light") across nvim background, btop and wallpaper.
local function apply_mode(mode)
  vim.o.background = mode
  set_btop_theme("flexoki-" .. mode)
  set_wallpaper(mode)
end

return {
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        apply_mode("dark")
      end,
      set_light_mode = function()
        apply_mode("light")
      end,
    },
  },
  {
    "mcchrish/zenbones.nvim",
    dependencies = { "rktjmp/lush.nvim" },
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.flexoki = {
        italic_strings = true,
        transparent_background = true,
        darkness = "warm",
        lightness = "dim",
      }
      vim.cmd.colorscheme("flexoki")
    end,
  },
}
