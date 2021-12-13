local lualine = require("lualine")
local onedark_custom = require("lualine.themes.onedark")
onedark_custom.normal.c.bg = "#282c34"

lualine.setup({
  options = { theme = onedark_custom }
})
