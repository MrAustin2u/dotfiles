return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "moon",
        transparent = true,
        dim_inactive = true,
        hide_inactive_statusline = true,
      })
      vim.cmd([[colorscheme tokyonight-moon]])
    end,
  },

  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
  },
}
