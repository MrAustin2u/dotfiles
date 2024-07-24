return {
  "folke/todo-comments.nvim",
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "TodoTrouble", "TodoTelescope" },
  dependencies = "nvim-lua/plenary.nvim",
  opts = {},
  keys = require("config.keymaps").todo_comments_mappings,
}
