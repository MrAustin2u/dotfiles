local icons = require "config.icons"

return {
  "SmiteshP/nvim-navic",
  opts = {
    icons = icons.kind,
    highlight = true,
    lsp = {
      auto_attach = true,
    },
    click = false,
    depth_limit = 0,
    depth_limit_indicator = "..",
  },
}
