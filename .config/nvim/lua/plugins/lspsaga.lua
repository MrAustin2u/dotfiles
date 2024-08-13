return {
  "glepnir/lspsaga.nvim",
  keys = function()
    return {
      { ",to", "<cmd>Lspsaga term_toggle<CR>", mode = { "n", "t" } },
      { ",so", "<cmd>Lspsaga outline<CR>", mode = { "n", "t" } },
    }
  end,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    symbol_in_winbar = {
      enable = true,
    },
    outline = {
      win_width = 50,
    },
    rename = {
      project_max_width = 1.0,
    },
  },
  config = function(_, opts)
    require("lspsaga").setup(opts)
  end,
}
