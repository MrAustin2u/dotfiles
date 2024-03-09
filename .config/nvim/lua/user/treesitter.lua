local M = {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  init = function(plugin)
    -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
    -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
    -- no longer trigger the **nvim-treeitter** module to be loaded in time.
    -- Luckily, the only thins that those plugins need are the custom queries, which lazy makes available
    -- during startup.
    require("lazy.core.loader").add_to_rtp(plugin)
    require("nvim-treesitter.query_predicates")
  end,
  dependencies = {
    "RRethy/nvim-treesitter-textsubjects",
    "nvim-treesitter/nvim-treesitter-textobjects",
    "windwp/nvim-ts-autotag",
    'JoosepAlviste/nvim-ts-context-commentstring',
    'IndianBoy42/tree-sitter-just',
  },
  opts = {
    autotag = { enable = true },
    endwise = { enable = true },
    ensure_installed = {
      "bash",
      "comment",
      "css",
      "csv",
      "diff",
      "dockerfile",
      "eex",
      "elixir",
      "erlang",
      "git_config",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
      "go",
      "gomod",
      "gosum",
      "gowork",
      "graphql",
      "heex",
      "html",
      "http",
      "javascript",
      "jsdoc",
      "json",
      "json5",
      "jsonc",
      "just",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "prisma",
      "python",
      "query",
      "regex",
      "rust",
      "scss",
      "sql",
      "ssh_config",
      "terraform",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
    },
    highlight = {
      additional_vim_regex_highlighting = false,
      enable = true,
      use_languagetree = true,
    },
    incremental_selection = { enable = true },
    indent = { enable = true },
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
          ["as"] = "@statement.outer"
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
        ['.'] = 'textsubjects-smart',
      }
    },
  },
}

function M.config(_, opts)
  if type(opts.ensure_installed) == "table" then
    ---@type table<string, boolean>
    local added = {}
    opts.ensure_installed = vim.tbl_filter(function(lang)
      if added[lang] then
        return false
      end
      added[lang] = true
      return true
    end, opts.ensure_installed)
  end
  require('tree-sitter-just').setup {}
  require("nvim-treesitter.configs").setup(opts)
end

return M
