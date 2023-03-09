return {
  "kyazdani42/nvim-tree.lua",
  dependencies = {
    'kyazdani42/nvim-web-devicons',
  },
  keys = {
    { "<leader>nf", "<cmd>NvimTreeFindFile<CR>", desc = "NvimTree - Toggle Find File" },
    { "<leader>nt", "<cmd>NvimTreeToggle<CR>",   desc = "NvimTree - Toggle" },
  },
  config = function()
    vim.cmd([[hi! NvimTreeNormalNC guibg=none ctermbg=none ]])
    vim.cmd([[hi! NvimTreeNormal guibg=none ctermbg=none ]])
    vim.cmd([[hi! NvimTreeWinSeparator guibg=none ctermbg=none ]])

    require("nvim-tree").setup({
      git = {
        ignore = false,
      },
      diagnostics = {
        enable = true,
      },
      filters = {
        exclude = { '.DS_Store' },
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
    })
    vim.g.nvim_tree_respect_buf_cwd = 1
    -- https://github.com/nvim-tree/nvim-tree.lua/wiki/Troubleshooting#fish
    vim.g.shell = "/bin/zsh"
  end,
}
