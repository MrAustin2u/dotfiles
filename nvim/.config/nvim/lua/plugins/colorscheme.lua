return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-moon]])
      require("tokyonight").setup({
        style = "moon",
        transparent = true,
        dim_inactive = true,
        hide_inactive_statusline = true,
      })
    end,
  },
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
  },
}
