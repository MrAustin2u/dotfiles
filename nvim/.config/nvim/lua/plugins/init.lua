local present, packer = pcall(require, "plugins.packer_init")

if not present then
	return false
end

return packer.startup(function(use)
	--[[ Manage self ]]
	use("wbthomason/packer.nvim")

	-- Speed up loading Lua modules in Neovim to improve startup time.
	use({ "lewis6991/impatient.nvim" })

	--[[ Snippets ]]
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			-- snippet engine, required by cmp
			{
				"L3MON4D3/LuaSnip",
				requires = {
					-- snippets!
					"rafamadriz/friendly-snippets",
				},
			},
			-- LSP driven completions
			"hrsh7th/cmp-nvim-lsp",
			-- completion from buffer text
			"hrsh7th/cmp-buffer",
			-- file path completion
			"hrsh7th/cmp-path",
			-- command line completion
			"hrsh7th/cmp-cmdline",
			-- neovim lua config api completion
			"hrsh7th/cmp-nvim-lua",
			-- emoji completion (triggered by `:`)
			"hrsh7th/cmp-emoji",
			-- snippets in completion sources
			"saadparwaiz1/cmp_luasnip",
			-- git completions
			"petertriho/cmp-git",
			-- tmux pane completion
			"andersevenrud/cmp-tmux",
		},
		config = function()
			require("plugins.cmp").setup()
		end,
	})

	--[[ LSP ]]

	-- installs/updates LSPs, linters and DAPs
	use({
		"williamboman/mason.nvim",
		requires = {
			-- handles connection of LSP Configs and Mason
			"williamboman/mason-lspconfig.nvim",

			-- Collection of configurations for the built-in LSP client
			"neovim/nvim-lspconfig",

			-- required for setting up capabilities for cmp
			"hrsh7th/cmp-nvim-lsp",

			-- elixir commands from elixirls
			{
				"mhanberg/elixir.nvim",
				requires = { "neovim/nvim-lspconfig", "nvim-lua/plenary.nvim" },
			},

			{
				"SmiteshP/nvim-navic",
				requires = "neovim/nvim-lspconfig",
			},
		},
		config = function()
			require("plugins.lsp").setup()
		end,
	})

	-- LSP UI utils
	use({
		"glepnir/lspsaga.nvim",
		branch = "main",
		config = function()
			require("plugins.lspsaga").setup()
		end,
	})

	-- automatically install tools using mason
	use({
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		requires = {
			"williamboman/mason.nvim",
		},
		config = function()
			require("plugins.mason-tool-installer").setup()
		end,
	})

	-- Use Neovim as a language server to inject LSP diagnostics, code
	-- actions, and more via Lua.
	use({
		"jose-elias-alvarez/null-ls.nvim",
		requires = {
			"nvim-lua/plenary.nvim",

			"lukas-reineke/lsp-format.nvim",
		},
		config = function()
			require("plugins.null-ls").setup()
		end,
	})

	-- show trailing white spaces and automatically delete them on write
	use({
		"zakharykaplan/nvim-retrail",
		config = function()
			require("plugins.retrail").setup()
		end,
	})

	-- Typescript
	use("jose-elias-alvarez/typescript.nvim")

	-- Makes mappings more discoverable using modals that show up after the prefix
	-- was pressed
	use({
		"anuvyklack/hydra.nvim",
		config = function()
			require("plugins.hydra").setup()
		end,
	})

	-- Function signature help via LSP
	use({
		"ray-x/lsp_signature.nvim",
		setup = function()
			require("lsp_signature").setup({ wrap = true })
		end,
	})

	--  Pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing.
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		config = function()
			require("plugins.trouble").setup()
		end,
	})

	use({
		"j-hui/fidget.nvim",
		config = function()
			require("fidget").setup({})
		end,
	})

	--[[ Navigation ]]
	use({
		"ThePrimeagen/harpoon",
		requires = { "nvim-lua/plenary.nvim" },
		config = function()
			require("core.mappings").harpoon_mappings()
		end,
	})

	-- File tree
	use({
		"kyazdani42/nvim-tree.lua",
		requires = { "kyazdani42/nvim-web-devicons" },
		config = function()
			require("plugins.nvimtree").setup()
		end,
	})

	-- smooth scrolling in neovim
	use({
		"declancm/cinnamon.nvim",
		config = function()
			require("cinnamon").setup()
		end,
	})

	use({
		"nvim-telescope/telescope.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
			"nvim-telescope/telescope-packer.nvim",
			"nvim-telescope/telescope-github.nvim",
			"olacin/telescope-cc.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
			"m-demare/attempt.nvim",
			"folke/tokyonight.nvim",
		},
		config = function()
			require("plugins.telescope").setup()
		end,
	})
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })

	-- Neovim dashboard
	use({
		"goolord/alpha-nvim",
		config = function()
			require("plugins.alpha").setup()
		end,
	})

	use({
		"ibhagwan/fzf-lua",
		requires = {
			"vijaymarupudi/nvim-fzf",
			"kyazdani42/nvim-web-devicons",
		}, -- optional for icons
	})
	use({ "nvim-telescope/telescope-ui-select.nvim" })

	--  Better syntax highlighting (and more)
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		requires = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"JoosepAlviste/nvim-ts-context-commentstring",
			"RRethy/nvim-treesitter-endwise",
			"nvim-treesitter/playground",
		},
		config = function()
			require("plugins.treesitter").setup()
		end,
	})

	-- Elixir support
	use("elixir-editors/vim-elixir")

	-- Rust support
	use({ "rust-lang/rust.vim", ft = { "rust" } })

	-- Git
	use({
		"lewis6991/gitsigns.nvim",
		requires = { "nvim-lua/plenary.nvim" },
		tag = "release",
		config = function()
			require("plugins.gitsigns")
		end,
	})

	use("rhysd/conflict-marker.vim")

	--[[ GIT ]]

	-- git integration
	use({
		"tpope/vim-fugitive",
		config = function()
			require("core.mappings").fugitive_mappings()
		end,
	})

	-- manage github gists
	use({ "mattn/gist-vim", cmd = "Gist", requires = { "mattn/webapi-vim" } })

	-- github support for fugitive
	use({
		"tpope/vim-rhubarb",
		requires = { "tpope/vim-fugitive" },
	})

	-- Color Theme
	use({
		"folke/tokyonight.nvim",
		config = function()
			require("tokyonight").setup({
				style = "storm",
				transparent = true,
			})

			vim.cmd([[colorscheme tokyonight]])
		end,
	})

	-- Highlight color hex codes with their color (fast!)
	use({
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({
				"*",
				"!packer",
			})
		end,
	})

	-- Highlight and search todo/fixme/hack etc comments
	use({
		"folke/todo-comments.nvim",
		requires = "nvim-lua/plenary.nvim",
		config = function()
			require("todo-comments").setup({})
		end,
	})

	-- Status line
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
		config = function()
			require("plugins.lualine").setup()
		end,
	})

	-- Comment out code easily
	use({
		"numToStr/Comment.nvim",
		requires = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("plugins.comment").setup()
		end,
	})

	-- delete unused buffers
	use({ "schickling/vim-bufonly", cmd = "BO" })

	use({
		"vim-test/vim-test",
		requires = "preservim/vimux",
	})

	use("aserowy/tmux.nvim")

	-- auto complete closable pairs
	use({
		"windwp/nvim-autopairs",
		config = function()
			require("plugins.nvim-autopairs").setup()
		end,
	})

	-- auto close html/tsx tags using TreeSitter
	use({
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup()
		end,
	})

	-- winbar file title and lsp path
	use({
		"utilyre/barbecue.nvim",
		requires = {
			"neovim/nvim-lspconfig",
			"smiteshp/nvim-navic",
			"nvim-tree/nvim-web-devicons",
		},
		after = "nvim-web-devicons",
		config = function()
			require("barbecue").setup()
		end,
	})

	-- automatically adjusts 'shiftwidth' and 'expandtab' heuristically
	use({ "tpope/vim-sleuth" })

	-- The ultimate undo history visualizer for VIM
	use({
		"mbbill/undotree",
		config = function()
			require("core.mappings").undotree_mappings()
		end,
	})

	use("folke/lua-dev.nvim")

	use({
		"andymass/vim-matchup",
		run = function()
			vim.g.loaded_matchit = 1
		end,
	})

	use({
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("plugins.indent-blankline").setup()
		end,
	})

	-- same as tabular but by Junegunn and way easier
	use({
		"junegunn/vim-easy-align",
		config = function()
			require("core.mappings").easy_align_mappings()
		end,
	})

	-- attempt stuff using scratch buffer and pre-configured bootstrap
	use({
		"m-demare/attempt.nvim",
		requires = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("plugins.attempt").setup()
		end,
	})

	--[[ TMUX ]]

	-- Tmux config file stuff
	use({ "tmux-plugins/vim-tmux", ft = "tmux" })

	-- Seamless tmux/vim pane navigation
	use({ "christoomey/vim-tmux-navigator" })

	-- Resize tmux panes and Vim windows with ease.
	use("RyanMillerC/better-vim-tmux-resizer")
end)
