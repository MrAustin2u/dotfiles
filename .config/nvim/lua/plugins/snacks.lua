return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    git = { enabled = true },
    lazygit = { enabled = true },
    words = { enabled = true },
    terminal = { enabled = true },
    bufdelete = { enabled = true },
    rename = { enabled = true },
    statuscolumn = { enabled = true },
    styles = {
      notification = {
        wo = { wrap = true }, -- Wrap notifications
      },
    },
  },
  keys = require("config.keymaps").snacks_mappings,
}
