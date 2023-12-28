return {
  {
    "nvim-treesitter/nvim-treesitter",
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/playground",
      "RRethy/nvim-treesitter-textsubjects",
      "windwp/nvim-ts-autotag",
      "RRethy/nvim-treesitter-endwise",
    },
    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    opts = {
      ensure_installed = "all",
      endwise = {
        enable = true,
      },
      ignore_install = { "liquidsoap" },
      indent = {
        enable = true,
      },
      highlight = {
        enable = true,
        use_languagetree = true,
        additional_vim_regex_highlighting = false,
      },
      autotag = {
        enable = true,
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["am"] = "@class.outer",
            ["im"] = "@class.inner",
            ["ac"] = "@comment.outer",
            ["as"] = "@statement.outer",
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
          },
          goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
          },
          goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
          },
          goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
          },
        },
      },
      textsubjects = {
        enable = true,
        keymaps = {
          ["."] = "textsubjects-smart",
        },
      },
    },
    config = function(_, opts)
      vim.g.skip_ts_context_commentstring_module = true

      if type(opts.ensure_installed) == "table" then
        local added = {}
        opts.ensure_installed = vim.tbl_filter(function(lang)
          if added[lang] then
            return false
          end
          added[lang] = true
          return true
        end, opts.ensure_installed)
      end

      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  -- Show context of the current function
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "VeryLazy" },
    enabled = true,
    opts = { mode = "cursor", max_lines = 3 },
  },
}
