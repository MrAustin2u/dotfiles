return {

  { "tpope/vim-repeat",         event = "VeryLazy" },

  "tpope/vim-surround",

  { "windwp/nvim-autopairs",    config = true },

  { "karb94/neoscroll.nvim",    config = true },

  { "tversteeg/registers.nvim", config = true },

  { "chentoast/marks.nvim",     config = true },

  { "mcauley-penney/tidy.nvim", config = true },

  "stsewd/gx-extended.vim",

  "benizi/vim-automkdir",

  "ellisonleao/glow.nvim",

  "superhawk610/ascii-blocks.nvim",

  "simeji/winresizer",

  "xiyaowong/nvim-transparent",

  -- LANGUAGE SUPPORT
  "mattn/emmet-vim",
  -- graphql support
  "jparise/vim-graphql",

  -- Better quickfix
  { "kevinhwang91/nvim-bqf", ft = "qf" },
  -- Columns
  "Bekaboo/deadcolumn.nvim",
  {
    "lukas-reineke/virt-column.nvim",
    config = function()
      require("virt-column").setup()
      vim.cmd([[ au VimEnter * highlight VirtColumn guifg=#1e2030 gui=nocombine ]])
    end,
  },
  {
    "mattn/vim-gist",
    dependencies = { "mattn/webapi-vim" },
    config = function()
      vim.g.gist_clip_command = "pbcopy"
      vim.g.gist_detect_filetype = 1
      vim.g.gist_open_browser_after_post = 1
      vim.g.gist_post_private = 1
    end,
  },
}
