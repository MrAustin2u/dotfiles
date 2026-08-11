-- The nvim half of seamless ctrl+h/j/k/l navigation.
--
-- The herdr side (.config/herdr/plugins/seamless-navigation) forwards the
-- keypress here when nvim is the pane's foreground process. This moves between
-- nvim windows first and only asks herdr to focus a neighbouring pane once nvim
-- is already at an edge.
if vim.env.HERDR_ENV ~= "1" and (vim.env.HERDR_PANE_ID or "") == "" then
  return
end

vim.pack.add { "https://github.com/willfish/herdr-navigator.nvim" }

local ok, navigator = pcall(require, "herdr-navigator")
if not ok then
  return
end

-- setup() installs alt+h/j/k/l by default, which are herdr's resize keys here.
-- Each direction needs an explicit empty string: setup() deep-merges over the
-- defaults, so an empty mappings table would leave all four in place.
navigator.setup {
  herdr_executable = vim.env.HERDR_BIN_PATH or "herdr",
  mappings = { left = "", down = "", up = "", right = "" },
}

for _, navigation in ipairs {
  { key = "<c-h>", name = "left", vim_direction = "h" },
  { key = "<c-j>", name = "down", vim_direction = "j" },
  { key = "<c-k>", name = "up", vim_direction = "k" },
  { key = "<c-l>", name = "right", vim_direction = "l" },
} do
  vim.keymap.set({ "n", "x", "s" }, navigation.key, function()
    navigator[navigation.name]()
  end, { desc = "Navigate " .. navigation.name })

  vim.keymap.set("t", navigation.key, function()
    navigator.navigate_terminal(navigation.vim_direction, navigation.name)
  end, { desc = "Navigate " .. navigation.name })
end
