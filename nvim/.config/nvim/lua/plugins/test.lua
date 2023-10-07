return {
  {
    "janko-m/vim-test",
    keys = require("config.keymaps").vim_test_mappings,
    dependencies = { "benmills/vimux" },
    init = function()
      vim.g["test#strategy"] = "vimux"
      -- accommodations for Malomo's unusual folder structure on Dash
      vim.cmd(
        [[let test#javascript#jest#file_pattern = '\v(__tests__/.*|(spec|test|__tests__))\.(js|jsx|coffee|ts|tsx)$']]
      )
    end,
  },
}
