local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

require("packer").startup(function(use)
	-- Manage self
	use("wbthomason/packer.nvim")

	-- LSP
	use({
		"williamboman/nvim-lsp-installer",
		"neovim/nvim-lspconfig",
		config = [[ require "aa.lsp" ]],
	})

	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
	})
	use({
		"jose-elias-alvarez/null-ls.nvim",
		"jose-elias-alvarez/nvim-lsp-ts-utils",
		"jose-elias-alvarez/typescript.nvim",
		requires = { "nvim-lua/plenary.nvim" },
	})
	use("ray-x/lsp_signature.nvim")
	use("nvim-lua/lsp_extensions.nvim")
	use("nvim-lua/lsp-status.nvim")
	use("b0o/SchemaStore.nvim")
	use({
		"j-hui/fidget.nvim",
		config = function()
			require("fidget").setup({})
		end,
	})

	-- Completion
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"onsails/lspkind-nvim",
		},
		config = [[ require "aa.plugins.completion" ]],
	})

	--Navigation
	use({
		"kyazdani42/nvim-tree.lua",
		requires = {
			"kyazdani42/nvim-web-devicons", -- optional, for file icon
		},
		tag = "nightly",
		config = [[ require "aa.plugins.nvim-tree" ]],
	})
	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
		},
		config = [[ require "aa.plugins.telescope" ]],
	})
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
	use({
		"goolord/alpha-nvim",
		config = [[ require "aa.plugins.alpha" ]],
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
		config = [[ require "aa.plugins.treesitter" ]],
	})

	-- Languages
	use("elixir-editors/vim-elixir")

	-- Git

	use({
		"lewis6991/gitsigns.nvim",
		requires = { "nvim-lua/plenary.nvim" },
		config = [[ require "aa.plugins.gitsigns" ]],
		tag = "release",
	})

	use("rhysd/conflict-marker.vim")
	use("tpope/vim-fugitive")

	-- Theme
	use({
		--[[ "EdenEast/nightfox.nvim", ]]
		"ellisonleao/gruvbox.nvim",
		config = [[ require "aa.plugins.colorscheme" ]],
	})

	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
		config = [[ require "aa.plugins.lualine" ]],
	})

	-- Pretty colors
	use({ "norcalli/nvim-colorizer.lua", config = [[ require "aa.plugins.colorizer" ]] })
	use("norcalli/nvim-terminal.lua")

	-- Tools
	use({
		"numToStr/Comment.nvim",
		config = [[ require "aa.plugins.comment" ]],
	})
	use({
		"vim-test/vim-test",
		requires = "preservim/vimux",
		config = [[ require "aa.plugins.vimtest" ]],
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
		config = [[ require "aa.plugins.indent-blankline" ]],
	})

	use({
		"akinsho/bufferline.nvim",
		tag = "v2.*",
		requires = "kyazdani42/nvim-web-devicons",
		config = [[ require "aa.plugins.bufferline" ]],
	})

	use("ojroques/nvim-bufdel")

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require("packer").sync()
	end
end)
