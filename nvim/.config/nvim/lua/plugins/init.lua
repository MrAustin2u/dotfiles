require("lazy").setup({
  -- UI
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    dim_inactive = true,
    hide_inactive_statusline = true,
    config = function()
      require("plugins.colorscheme").setup()
    end,
  },
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "WhoIsSethDaniel/lualine-lsp-progress",
    },
    config = function()
      require("plugins.lualine").setup()
    end,
  },
  {
    "noib3/nvim-cokeline",
    lazy = false,
    dependencies = {
      "kyazdani42/nvim-web-devicons",
    },
    config = function()
      require("plugins.cokeline").setup()
    end,
  },
  {
    "glepnir/dashboard-nvim",
    event = "VimEnter",
    config = function()
      require("plugins.dashboard").setup()
    end,
  },

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
  -- Better `vim.notify()`
  {
    "rcarriga/nvim-notify",
    config = function()
      require("plugins.vim-notify").setup()
    end,
  },

  -- better vim.ui
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  -- noicer ui
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    config = function()
      require("plugins.noice").setup()
    end,
  },

  -- CODING STUFF
  {
    "nvim-treesitter/nvim-treesitter",
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = "BufReadPost",
    keys = {
      { "<c-space>", desc = "Increment selection" },
      { "<bs>", desc = "Schrink selection", mode = "x" },
    },
    config = function()
      require("plugins.treesitter").setup()
    end,
  },
  {
    "m-demare/attempt.nvim",
    config = function()
      require("plugins.attempt").setup()
    end,
  },
  {
    "uga-rosa/ccc.nvim",
    config = function()
      require("ccc").setup({
        highlighter = {
          auto_enable = true,
        },
      })
    end,
  },
  {
    "bennypowers/nvim-regexplainer",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("plugins.regexplainer").setup()
    end,
  },

  -- EDITOR STUFF
  -- file tree
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("plugins.nvimtree").setup()
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false, -- telescope did only one release, so use HEAD for now
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-file-browser.nvim",
      "olacin/telescope-cc.nvim",
      "m-demare/attempt.nvim",
      "nvim-telescope/telescope-github.nvim",
      "folke/tokyonight.nvim",
    },
    config = function()
      require("plugins.telescope").setup()
    end,
  },
  {
    "krivahtoo/silicon.nvim",
    build = "./install.sh build",
    cmd = "Silicon",
    config = function()
      require("plugins.silicon").setup()
    end,
  },

  {
    "windwp/nvim-spectre",
    config = function()
      require("plugins.spectre").setup()
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    event = "VeryLazy",
    version = "*",
    config = function()
      require("plugins.toggleterm").setup()
    end,
  },
  {
    "lalitmee/browse.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("plugins.browse").setup()
    end,
  },
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "kyazdani42/nvim-web-devicons",
    },
    config = function()
      require("plugins.octo").setup()
    end,
  },
  {
    "rest-nvim/rest.nvim",
    config = function()
      require("core.keymaps").rest_mappings()
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
    },
    config = function()
      require("plugins.whichkey").setup()
    end,
  },

  -- Utilities

  -- measure startuptime
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },

  -- session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help" } },
    config = function()
      require("core.keymaps").persistence_mappings()
    end,
  },

  -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },

  -- makes some plugins dot-repeatable like leap
  { "tpope/vim-repeat", event = "VeryLazy" },

  "tpope/vim-surround",

  "tpope/vim-abolish",

  { "szw/vim-maximizer", keys = { { "<space>m", ":MaximizerToggle <CR>" } } },
  { "windwp/nvim-autopairs", config = true },

  { "karb94/neoscroll.nvim", config = true },

  "famiu/bufdelete.nvim",

  { "tversteeg/registers.nvim", config = true },

  { "chentoast/marks.nvim", config = true },

  "dstein64/vim-startuptime",

  { "mcauley-penney/tidy.nvim", config = true },

  "stsewd/gx-extended.vim",

  "rhysd/clever-f.vim",

  { "folke/todo-comments.nvim", config = true },

  { "numToStr/Comment.nvim", config = true },

  "benizi/vim-automkdir",

  "gpanders/editorconfig.nvim",

  "ellisonleao/glow.nvim",

  "mong8se/actually.nvim",

  "superhawk610/ascii-blocks.nvim",

  {
    "lukas-reineke/virt-column.nvim",
    config = function()
      require("virt-column").setup()
      vim.cmd([[ au VimEnter * highlight VirtColumn guifg=#1e2030 gui=nocombine ]])
    end,
  },

  -- Window hacks
  { "luukvbaal/stabilize.nvim", config = true },

  "simeji/winresizer",

  "xiyaowong/nvim-transparent",

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

  -- Frontend
  "mattn/emmet-vim",

  -- Better quickfix
  { "kevinhwang91/nvim-bqf", ft = "qf" },

  -- Better wildmenu
  {
    "gelguy/wilder.nvim",
    config = function()
      require("wilder").setup({ modes = { ":", "/", "?" } })
    end,
  },

  -- LSP STUFF
  {
    "williamboman/mason.nvim",
    dependencies = {
      -- handles connection of LSP Configs and Mason
      "williamboman/mason-lspconfig.nvim",
      -- Collection of configurations for the built-in LSP client
      "neovim/nvim-lspconfig",
      -- required for setting up capabilities for cmp
      "hrsh7th/cmp-nvim-lsp",
      {
        "SmiteshP/nvim-navic",
        dependencies = "neovim/nvim-lspconfig",
      },

      -- elixir commands from elixirls
      {
        "elixir-tools/elixir-tools.nvim",
        dependencies = { "neovim/nvim-lspconfig", "nvim-lua/plenary.nvim" },
      },
    },
    config = function()
      require("plugins.lsp").setup()
    end,
  },

  -- diagnostics
  {
    "folke/trouble.nvim",
    config = function()
      require("plugins.trouble").setup()
    end,
  },
  -- elixir
  {
    "kevinkoltz/vim-textobj-elixir",
    dependencies = { "kana/vim-textobj-user" },
    ft = { "elixir" },
  },
  {
    "lucidstack/hex.vim",
    ft = { "elixir" },
    dependencies = { "mattn/webapi-vim" },
  },

  -- Neovim as a language server to inject LSP diagnostics, code
  -- actions, and more via Lua.
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",

      "lukas-reineke/lsp-format.nvim",
    },
    config = function()
      require("plugins.null-ls").setup()
    end,
  },

  -- LSP UI utils
  {
    "glepnir/lspsaga.nvim",
    branch = "main",
    config = function()
      require("plugins.lspsaga").setup()
    end,
  },

  -- LANGUAGE STUFF

  {
    "tpope/vim-dadbod",
    cmd = "DBUI",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
    config = function()
      require("plugins.dadbod").setup()
    end,
  },

  -- COMPLETION STUFF
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        dependencies = {
          -- snippets!
          "rafamadriz/friendly-snippets",
        },
      },
      "andersevenrud/cmp-tmux",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
      "petertriho/cmp-git",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      require("plugins.cmp").setup()
    end,
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("plugins.copilot").setup()
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    config = true,
  },

  -- GIT

  {
    "sindrets/diffview.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" },
  },
  {
    "ruifm/gitlinker.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("gitlinker").setup()
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("plugins.gitsigns").setup()
    end,
  },
})
