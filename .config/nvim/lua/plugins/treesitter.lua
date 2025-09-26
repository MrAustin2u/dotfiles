return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/playground",
    "RRethy/nvim-treesitter-textsubjects",
    "JoosepAlviste/nvim-ts-context-commentstring",
    "IndianBoy42/tree-sitter-just",
    "nvim-treesitter/nvim-treesitter-context",
  },
  config = function()
    require("tree-sitter-just").setup {}
    require("treesitter-context").setup {
      enable = true,
      max_lines = 3,
      trim_scope = "outer",
      mode = "cursor",
    }
    require("nvim-treesitter.configs").setup {
      modules = {},
      sync_install = false,
      ignore_install = {},
      auto_install = true,
      ensure_installed = {
        "angular",
        "bash",
        "c",
        "diff",
        "eex",
        "elixir",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "glsl",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "hcl",
        "heex",
        "html",
        "http",
        "javascript",
        "jsdoc",
        "json",
        "json5",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "terraform",
        "tmux",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      indent = {
        enable = true,
        disable = function(_, buf)
          local max_filesize = 10 * 1024 -- 10 KB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },
      highlight = {
        enable = true,
        use_languagetree = true,
        additional_vim_regex_highlighting = false,
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
    }
  end,
}
