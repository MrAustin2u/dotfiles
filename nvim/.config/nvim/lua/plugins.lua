return {
  -- UI
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
  -- EDITOR STUFF
  {
    "rest-nvim/rest.nvim",
    config = function()
      require("keymaps").rest_mappings()
    end,
  },
  -- references
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = { delay = 200 },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
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
      require("keymaps").persistence_mappings()
    end,
  },

  -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },

  -- makes some plugins dot-repeatable like leap
  { "tpope/vim-repeat",      event = "VeryLazy" },

  "tpope/vim-surround",

  "tpope/vim-abolish",

  { "szw/vim-maximizer",     keys = { { "<space>m", ":MaximizerToggle <CR>" } } },
  { "windwp/nvim-autopairs", config = true },

  { "karb94/neoscroll.nvim", config = true },

  "famiu/bufdelete.nvim",

  { "tversteeg/registers.nvim", config = true },

  { "chentoast/marks.nvim",     config = true },

  "dstein64/vim-startuptime",

  { "mcauley-penney/tidy.nvim", config = true },

  "stsewd/gx-extended.vim",

  "rhysd/clever-f.vim",

  { "folke/todo-comments.nvim", config = true },

  { "numToStr/Comment.nvim",    config = true },

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
  { "kevinhwang91/nvim-bqf",    ft = "qf" },

  -- Better wildmenu
  {
    "gelguy/wilder.nvim",
    config = function()
      require("wilder").setup({ modes = { ":", "/", "?" } })
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
  -- GIT
  { "ruifm/gitlinker.nvim", config = true },
  {
    "sindrets/diffview.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons" },
  },
}
