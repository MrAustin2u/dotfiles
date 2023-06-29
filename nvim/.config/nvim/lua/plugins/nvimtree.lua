return {
  "nvim-tree/nvim-tree.lua",
  cmd = "NvimTreeToggle",
  keys = require("keymaps").nvim_tree_mappings(),
  config = function()
    local nvimtree = require("nvim-tree")

    local config = {
      git = {
        ignore = false,
      },
      diagnostics = {
        enable = true,
      },
      filters = {
        exclude = { ".DS_Store" },
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
    }

    vim.cmd([[hi! NvimTreeNormalNC guibg=none ctermbg=none ]])
    vim.cmd([[hi! NvimTreeNormal guibg=none ctermbg=none ]])
    vim.cmd([[hi! NvimTreeWinSeparator guibg=none ctermbg=none ]])

    nvimtree.setup(config)
    vim.g.nvim_tree_respect_buf_cwd = 1
    -- https://github.com/nvim-tree/nvim-tree.lua/wiki/Troubleshooting#fish
    vim.g.shell = "/bin/zsh"
  end,
}
