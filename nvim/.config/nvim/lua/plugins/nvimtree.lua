local present, nvimtree = pcall(require, 'nvim-tree')

if not present then
  return
end

local config = {
  renderer = {
    icons = {
      show = {
        git = true,
        folder = true,
        file = true,
        folder_arrow = true,
      },
      glyphs = {
        default = '',
        git = {
          unstaged = '',
          staged = '',
          unmerged = '',
          renamed = '',
          untracked = '',
          deleted = '',
        },
      },
    },
  },
  hijack_netrw = true,
  diagnostics = {
    enable = true,
    show_on_dirs = false,
    icons = {
      hint = '',
      info = '',
      warning = '',
      error = '',
    },
  },
  filters = {
    dotfiles = false,
    custom = { '.DS_Store', 'fugitive:', '.git' },
    exclude = {},
  },
  view = {
    width = 50,
    side = 'right',
  },
}

local M = {}

M.setup = function()
  vim.g.nvim_tree_git_hl = 1
  vim.g.nvim_tree_highlight_opened_files = 2

  nvimtree.setup(config)
  require('core.mappings').nvim_tree_mappings()
end

return M
