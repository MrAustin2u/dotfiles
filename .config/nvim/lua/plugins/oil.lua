return {
  "stevearc/oil.nvim",
  event = { "VimEnter" },
  keys = require("config.keymaps").oil_mappings(),
  opts = {
    default_file_explorer = true,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    columns = { "icon" },
    keymaps = {
      ["<C-c>"] = false,
      ["q"] = "actions.close",
      [">"] = "actions.toggle_hidden",
    },
    view_options = {
      show_hidden = true,
      natural_order = true,
      is_always_hidden = function(name, _bufnr)
        return name == ".." or name == ".git"
      end,
    },

    float = {
      -- Padding around the floating window
      padding = 8,
      max_width = 120,
      max_height = 120,
    },
  },
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
