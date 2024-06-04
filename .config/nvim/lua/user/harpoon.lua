local M = {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    menu = {
      width = vim.api.nvim_win_get_width(0) - 4,
    },
    settings = {
      save_on_toggle = true,
    },
  }
}

function M.config(_, opts)
  local harpoon = require("harpoon")

  harpoon:setup(opts)

  -- mappings
  vim.keymap.set("n", "<leader>a", function()
      harpoon:list():add()
      vim.notify "󱡅  marked file"
    end,
    { noremap = true, silent = true, desc = "Harpoon Add File" })
  vim.keymap.set("n", "<TAB>", function() harpoon:list():next() end,
    { noremap = true, silent = true, desc = "Harpoon Next Buffer" })
  vim.keymap.set("n", "<S-TAB>", function() harpoon:list():prev() end,
    { noremap = true, silent = true, desc = "Harpoon Previous Buffer" })
  vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
    { noremap = true, silent = true, desc = "Harpoon Quick Menu" })
end

return M
