return {
  "mrjones2014/legendary.nvim", -- A command palette for keymaps, commands and autocmds
  priority = 10000,
  lazy = false,
  dependencies = "kkharji/sqlite.lua",
  init = function()
    require("legendary").keymaps {
      {
        "<C-p>",
        require("legendary").find,
        hide = true,
        description = "Open Legendary",
        mode = { "n", "v" },
      },
    }
  end,
  config = function()
    require("legendary").setup {
      select_prompt = "Legendary",
      include_builtin = false,
      -- Load these with the plugin to ensure they are loaded before any Neovim events
      autocmds = require "config.autocmds",
    }
  end,
}
