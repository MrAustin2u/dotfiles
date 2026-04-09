return {
  "SmiteshP/nvim-navic",
  lazy = true,
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("nvim-navic").setup {
      highlight = true,
      depth_limit = 5,
      lazy_update_context = true,
      safe_output = true,
    }
  end,
}