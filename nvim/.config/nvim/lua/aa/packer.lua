local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require("packer").startup(function(use)
  -- Manage self
  use("wbthomason/packer.nvim")

  -- LSP
  use({
    "VonHeikemen/lsp-zero.nvim",
    requires = {
      -- LSP Support
      "neovim/nvim-lspconfig",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",

      -- Autocompletion
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",

      -- Snippets
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
    },
  })

  use({
    "jose-elias-alvarez/null-ls.nvim",
    requires = { "nvim-lua/plenary.nvim" },
  })

  use("b0o/SchemaStore.nvim")
  use({
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup({})
    end,
  })
  use("RRethy/vim-illuminate")
  use("simrat39/inlay-hints.nvim")

  --Navigation
  use({
    "kyazdani42/nvim-tree.lua",
    requires = {
      "kyazdani42/nvim-web-devicons", -- optional, for file icon
    },
    tag = "nightly",
  })

  use({
    "nvim-telescope/telescope.nvim",
    requires = {
      "nvim-lua/plenary.nvim",
    },
  })
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
  use({
    "goolord/alpha-nvim",
  })

  use({
    "ibhagwan/fzf-lua",
    requires = {
      "vijaymarupudi/nvim-fzf",
      "kyazdani42/nvim-web-devicons",
    }, -- optional for icons
  })
  use({ "nvim-telescope/telescope-ui-select.nvim" })

  --Syntax
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    requires = {
      "windwp/nvim-ts-autotag",
      "p00f/nvim-ts-rainbow",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
  })

  -- Languages
  use("elixir-editors/vim-elixir")

  -- Git
  use({
    "lewis6991/gitsigns.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    tag = "release",
  })

  use("rhysd/conflict-marker.vim")
  use("tpope/vim-fugitive")

  -- Theme
  use({
    "EdenEast/nightfox.nvim",
  })

  use({
    "nvim-lualine/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true },
  })

  -- Pretty colors
  use("norcalli/nvim-terminal.lua")

  -- Tools
  use({
    "numToStr/Comment.nvim",
  })
  use({
    "vim-test/vim-test",
    requires = "preservim/vimux",
  })

  use("aserowy/tmux.nvim")
  use("windwp/nvim-autopairs")
  use("lewis6991/impatient.nvim")
  use("folke/lua-dev.nvim")
  use({
    "andymass/vim-matchup",
    run = function()
      vim.g.loaded_matchit = 1
    end,
  })
  use({
    "lukas-reineke/indent-blankline.nvim",
  })

  use("ojroques/nvim-bufdel")

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require("packer").sync()
  end
end)
