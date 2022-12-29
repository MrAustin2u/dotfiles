vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_highlight_opened_files = 2

require("nvim-tree").setup({
  view = {
    width = 50,
    side = "right",
  },
  filters = {
    dotfiles = false,
  },
})
