local present, nvimtree = pcall(require, "nvim-tree")

if not present then
  return
end

local M = {}

M.setup = function()
  local config = {
    git = {
      ignore = false,
    },
    diagnostics = {
      enable = true,
      show_on_dirs = false,
      icons = {
        hint = "",
        info = "",
        warning = "",
        error = "",
      },
    },
    filters = {
      dotfiles = false,
      custom = { ".DS_Store", ".git" },
      exclude = {},
    },
    view = {
      width = 45,
      side = "right",
    },
    actions = {
      change_dir = {
        enable = false,
        global = false,
      },
      open_file = {
        quit_on_open = true,
      },
    },
    renderer = {
      icons = {
        show = {
          git = true,
          folder = true,
          file = true,
          folder_arrow = true,
        },
        glyphs = {
          default = "",
          git = {
            unstaged = "",
            staged = "",
            unmerged = "",
            renamed = "",
            untracked = "",
            deleted = "",
          },
        },
      },
    },
  }

  vim.cmd([[hi! NvimTreeNormalNC guibg=none ctermbg=none ]])
  vim.cmd([[hi! NvimTreeNormal guibg=none ctermbg=none ]])
  vim.cmd([[hi! NvimTreeWinSeparator guibg=none ctermbg=none ]])

  nvimtree.setup(config)
  vim.g.nvim_tree_respect_buf_cwd = 1
  -- https://github.com/nvim-tree/nvim-tree.lua/wiki/Troubleshooting#fish
  vim.g.shell = "/bin/zsh"
end

return M
