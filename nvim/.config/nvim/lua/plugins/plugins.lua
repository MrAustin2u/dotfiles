return {

  {
    "andymass/vim-matchup",
    build = function()
      vim.g.loaded_matchit = 1
      vim.g.matchup_surround_enabled = true
      vim.g.matchup_matchparen_deferred = true
      vim.g.matchup_matchparen_offscreen = {
        method = "popup",
        fullwidth = true,
        highlight = "Normal",
        border = "shadow",
      }
    end,
  },

  {
    "zakharykaplan/nvim-retrail",
    opts = {
      -- Highlight group to use for trailing whitespace.
      hlgroup = "IncSearch",
      -- Enabled filetypes.
      filetype = {
        -- Excluded filetype list. Overrides `include` list.
        exclude = {
          "",
          "TelescopePrompt",
          "Trouble",
          "WhichKey",
          "alpha",
          "checkhealth",
          "diff",
          "fugitive",
          "fzf",
          "git",
          "gitcommit",
          "help",
          "lspinfo",
          "lspsagafinder",
          "lspsagaoutline",
          "man",
          "markdown",
          "mason",
          "null-ls-info",
          "qf",
          "unite",
          "neotree",
        },
      },
    },
  },

  -- Utilities
  'tpope/vim-surround',

  'tpope/vim-abolish',

  { 'szw/vim-maximizer',     keys = { { '<space>m', ':MaximizerToggle <CR>' } } },
  { 'windwp/nvim-autopairs', config = true },

  { 'karb94/neoscroll.nvim', config = true },

  'famiu/bufdelete.nvim',

  { 'tversteeg/registers.nvim', config = true },

  { 'chentoast/marks.nvim',     config = true },

  'dstein64/vim-startuptime',

  { 'mcauley-penney/tidy.nvim', config = true },

  'stsewd/gx-extended.vim',

  'rhysd/clever-f.vim',

  { 'folke/todo-comments.nvim', config = true },

  { 'numToStr/Comment.nvim',    config = true },

  'benizi/vim-automkdir',

  'gpanders/editorconfig.nvim',

  'ellisonleao/glow.nvim',

  'mong8se/actually.nvim',

  'superhawk610/ascii-blocks.nvim',

  {
    'lukas-reineke/virt-column.nvim',
    config = function()
      require('virt-column').setup()
      vim.cmd [[ au VimEnter * highlight VirtColumn guifg=#1e2030 gui=nocombine ]]
    end
  },

  -- Window hacks
  { 'luukvbaal/stabilize.nvim', config = true },

  'simeji/winresizer',

  'xiyaowong/nvim-transparent',

  -- Better Git
  { 'sindrets/diffview.nvim',   dependencies = { 'kyazdani42/nvim-web-devicons' } },
  { 'ruifm/gitlinker.nvim',     config = true },

  {
    'mattn/vim-gist',
    dependencies = { 'mattn/webapi-vim' },
    config = function()
      vim.g.gist_clip_command = 'pbcopy'
      vim.g.gist_detect_filetype = 1
      vim.g.gist_open_browser_after_post = 1
      vim.g.gist_post_private = 1
    end
  },

  -- Frontend
  'mattn/emmet-vim',

  -- Better quickfix
  { 'kevinhwang91/nvim-bqf', ft = 'qf' },

  -- Better wildmenu
  { 'gelguy/wilder.nvim',    config = function() require('wilder').setup({ modes = { ':', '/', '?' } }) end },
}
