local M = {
  "ThePrimeagen/harpoon",
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
  },
}

function M.config()
  require("harpoon").setup({
    tabline = true,
    tabline_prefix = "   ",
    tabline_suffix = "   ",
  })

  -- mappings
  local ui = require("harpoon.ui")
  local opts = { noremap = true, silent = true }
  vim.keymap.set("n", "<leader>a", "<cmd>lua require('user.harpoon').mark_file()<cr>", opts)
  vim.keymap.set("n", "<TAB>", ui.nav_next, opts)
  vim.keymap.set("n", "<S-TAB>", ui.nav_prev, opts)
  vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, opts)


  -- make the tabline cleaner
  vim.cmd('highlight! HarpoonInactive guibg=NONE guifg=#63698c')
  vim.cmd('highlight! HarpoonActive guibg=NONE guifg=white')
  vim.cmd('highlight! HarpoonNumberActive guibg=NONE guifg=#7aa2f7')
  vim.cmd('highlight! HarpoonNumberInactive guibg=NONE guifg=#7aa2f7')
  vim.cmd('highlight! TabLineFill guibg=NONE guifg=white')
end

function M.mark_file()
  require("harpoon.mark").add_file()
  vim.notify "󱡅  marked file"
end

return M
