local M = {
  "ThePrimeagen/harpoon",
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
  },
}

function M.config()
  local ui = require("harpoon.ui")

  local opts = { noremap = true, silent = true }
  vim.keymap.set("n", "<leader>a", "<cmd>lua require('user.harpoon').mark_file()<cr>", opts)
  vim.keymap.set("n", "<TAB>", ui.nav_next, opts)
  vim.keymap.set("n", "<S-TAB>", ui.nav_prev, opts)
  vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, opts)
end

function M.mark_file()
  require("harpoon.mark").add_file()
  vim.notify "󱡅  marked file"
end

return M
