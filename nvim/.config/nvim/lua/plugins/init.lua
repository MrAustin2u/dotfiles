require("lazy").setup({
  -- COMPLETION
  {
    "L3MON4D3/LuaSnip",
    build = (not jit.os:find("Windows"))
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    -- stylua: ignore
    keys = {
      {
        "<Tab>",
        function()
          return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
        end,
        expr = true,
        silent = true,
        mode = "i",
      },
      {
        "<Tab>",
        function() require("luasnip").jump(1) end,
        mode = "s",
        { "<S-Tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "andersevenrud/cmp-tmux",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      -- "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-vsnip",
      "hrsh7th/vim-vsnip",
      "onsails/lspkind.nvim",
      "saadparwaiz1/cmp_luasnip",
      {
        "zbirenbaum/copilot-cmp",
        dependencies = "copilot.lua",
        opts = {},
        config = function(_, opts)
          local copilot_cmp = require("copilot_cmp")
          copilot_cmp.setup(opts)
          -- attach cmp source whenever copilot attaches
          -- fixes lazy-loading issues with the copilot cmp source
          require("utils").on_attach(function(client)
            if client.name == "copilot" then
              copilot_cmp._on_insert_enter({})
            end
          end)
        end,
      },
    },
    config = function()
      require("plugins.cmp").setup()
    end,
  },
  -- copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    config = function()
      require("plugins.copilot").setup()
    end,
  },

  -- LSP STUFF

  {
    "williamboman/mason.nvim",
    event = "VeryLazy",
    keys = { { "<leader>cm", "<cmd>MasonUpdate<CR>" } },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "jose-elias-alvarez/typescript.nvim",
      "glepnir/lspsaga.nvim",
      { "elixir-tools/elixir-tools.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    },
    config = function()
      require("plugins.lsp").setup()
    end,
  },
  {
    "mhanberg/output-panel.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "jose-elias-alvarez/typescript.nvim",
      "lukas-reineke/lsp-format.nvim",
    },
    config = function()
      require("plugins.null-ls").setup()
    end,
  },
  -- lsp renaming
  {
    "smjonas/inc-rename.nvim",
    config = function()
      require("inc_rename").setup()
    end,
  },
  -- lsp ui utils
  {
    "glepnir/lspsaga.nvim",
    event = "VeryLazy",
    branch = "main",
    config = function()
      require("plugins.lspsaga").setup()
    end,
  },
  {
    "folke/trouble.nvim",
    keys = require("keymaps").trouble_mappings(),
    config = function()
      require("trouble").setup()
    end,
  },

  -- COKELINE

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

  -- LUALINE
  {
    "nvim-lualine/lualine.nvim",
    -- dependencies = {
    --   "WhoIsSethDaniel/lualine-lsp-progress",
    --   opt = true,
    -- },
    config = function()
      require("plugins.lualine").setup()
    end,
  },

  -- ATTEMPT

  {
    "m-demare/attempt.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("plugins.attempt").setup()
    end,
  },

  -- DASHBOARD

  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    config = function()
      require("plugins.dashboard").setup()
    end,
  },

  -- UI

  {
    "rcarriga/nvim-notify",
    config = function()
      require("plugins.vim-notify").setup()
    end,
  },
  -- color schemes
  {
    "folke/tokyonight.nvim",
    lazy = false, -- make sure we load this during startup
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("tokyonight").setup({
        style = "moon",
        transparent = true,
        dim_inactive = true,
        hide_inactive_statusline = true,
      })

      vim.cmd([[colorscheme tokyonight-moon]])
      vim.cmd([[hi TabLine guibg=NONE guifg=NONE]])
    end,
  },
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      integrations = {
        alpha = true,
        cmp = true,
        gitsigns = true,
        illuminate = true,
        -- indent_blankline = { enabled = true },
        lsp_trouble = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        neotest = true,
        noice = true,
        notify = true,
        nvimtree = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        which_key = true,
      },
    },
  },
  {
    "folke/noice.nvim",
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    enabled = true,
    event = "VeryLazy",
    config = function()
      require("plugins.noice").setup()
    end,
  },
  -- highlight color hex codes with their color (fast!)
  {
    "norcalli/nvim-colorizer.lua",
    event = "VeryLazy",
    opts = {
      "*",
      "!lazy",
    },
  },
  "Bekaboo/deadcolumn.nvim",
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

  -- CODING STUFF

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
  --test
  {
    "nvim-neotest/neotest",
    dependencies = {
      "jfpedroza/neotest-elixir",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
    },
    config = function()
      require("plugins.test").setup()
    end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/neotest",
    },
    optional = true,
    -- stylua: ignore
    keys = {
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug Nearest" },
    },
  },

  -- EDITOR STUFF

  {
    "kevinhwang91/nvim-hlslens",
    config = function()
      require("plugins.hslens").setup()
    end,
  },

  -- better wildmenu
  {
    "gelguy/wilder.nvim",
    config = function()
      require("wilder").setup({ modes = { ":", "/", "?" } })
    end,
  },
  -- whichkey
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      defaults = {
        ["<leader>t"] = { name = "+test" },
      },
      plugins = { spelling = true },
    },
    config = function()
      require("plugins.whichkey").setup()
    end,
  },

  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "JoosepAlviste/nvim-ts-context-commentstring",
      "RRethy/nvim-treesitter-endwise",
      "nvim-treesitter/playground",
      "nvim-treesitter/nvim-treesitter-context",
    },
    config = function()
      require("plugins.treesitter").setup()
    end,
  },
  -- auto complete closable pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  -- auto close html/tsx tags using TreeSitter
  {
    "windwp/nvim-ts-autotag",
    ft = {
      "html",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "svelte",
      "vue",
      "tsx",
      "jsx",
      "xml",
      "php",
      "markdown",
    },
    event = "VeryLazy",
    opts = {},
  },
  -- file tree
  {
    "nvim-tree/nvim-tree.lua",
    cmd = "NvimTreeToggle",
    keys = require("keymaps").nvim_tree_mappings(),
    config = function()
      require("plugins.nvimtree").setup()
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
  {
    "krivahtoo/silicon.nvim",
    build = "./install.sh build",
    cmd = "Silicon",
    keys = require("keymaps").silicon_mappings(),
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
  -- references
  {
    "tzachar/local-highlight.nvim",
    config = function()
      vim.cmd([[hi TSDefinitionUsage guibg=#565f89]])

      require("local-highlight").setup()
    end,
  },

  -- TELESCOPE

  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
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

  -- TEST

  {
    "nvim-neotest/neotest",
    dependencies = {
      "jfpedroza/neotest-elixir",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
    },
    config = function()
      require("plugins.test").setup()
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
  -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },

  -- makes some plugins dot-repeatable like leap
  { "tpope/vim-repeat", event = "VeryLazy" },

  "tpope/vim-surround",

  "tpope/vim-abolish",

  { "szw/vim-maximizer", keys = { { "<space>m", "<cmd>MaximizerToggle<CR>" } } },
  { "windwp/nvim-autopairs", config = true },

  { "karb94/neoscroll.nvim", config = true },

  "famiu/bufdelete.nvim",

  { "tversteeg/registers.nvim", config = true },

  { "chentoast/marks.nvim", config = true },

  { "mcauley-penney/tidy.nvim", config = true },

  "stsewd/gx-extended.vim",

  { "folke/todo-comments.nvim", config = true },

  { "numToStr/Comment.nvim", config = true },

  "benizi/vim-automkdir",

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

  -- LANGUAGE SUPPORT
  "mattn/emmet-vim",
  -- graphql support
  "jparise/vim-graphql",

  -- Better quickfix
  { "kevinhwang91/nvim-bqf", ft = "qf" },

  -- GIT

  { "ruifm/gitlinker.nvim", config = true },
  {
    "sindrets/diffview.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.gitsigns").setup()
    end,
  },
}, {
  concurrency = 8,
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      ---@type string[] list any plugins you want to disable here
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
