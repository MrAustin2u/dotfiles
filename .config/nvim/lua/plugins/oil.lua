return {
  "stevearc/oil.nvim",
  -- we need this to work when running nvim .
  -- it's ok though because this only adds ~1.5ms to load time
  event = { "VimEnter" },
  keys = require("config.keymaps").oil_mappings(),
  opts = {
    columns = { "icon" },
    keymaps = {
      ["<C-c>"] = false,
      ["q"] = "actions.close",
      [">"] = "actions.toggle_hidden",
    },
    view_options = {
      show_hidden = true,
    },
  },
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
