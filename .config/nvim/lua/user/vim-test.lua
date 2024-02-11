local M = {
  "janko-m/vim-test",
  keys = require("config.keymaps").vim_test_mappings(),
  dependencies = {
    {
      "benmills/vimux",
      config = function()
        vim.g["VimuxOrientation"] = "h"
        vim.g["VimuxHeight"] = "35"
      end
    }
  },
  init = function()
    vim.g["test#strategy"] = "vimux"
    -- vim.g["test#strategy"] = "toggleterm"
    vim.g["test#preserve_screen"] = 0
    -- accommodations for Malomo's unusual folder structure on Dash
    vim.cmd(
      [[let test#javascript#jest#file_pattern = '\v(__tests__/.*|(spec|test|__tests__))\.(js|jsx|coffee|ts|tsx)$']])
  end,
}

function M.config() end

return M
