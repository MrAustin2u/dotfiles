local g = vim.g

g.nvim_tree_git_hl = 1
g.nvim_tree_highlight_opened_files = 2

require("nvim-tree").setup({
  view = {
    width = 45,
    side = "right",
  },
  filters = {
    dotfiles = false,
  },
})
