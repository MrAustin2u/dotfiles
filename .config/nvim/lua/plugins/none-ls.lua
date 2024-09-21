return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
    "nvim-lua/plenary.nvim",
    "williamboman/mason.nvim",
  },
  config = function()
    local null_ls = require "null-ls"

    null_ls.setup {
      sources = {
        ----------------------
        --   Code Actions   --
        ----------------------

        ----------------------
        --     Linters      --
        ----------------------

        ----------------------
        --    Diagnostics   --
        ----------------------
        require "none-ls.diagnostics.eslint_d",
        null_ls.builtins.diagnostics.actionlint,
        null_ls.builtins.diagnostics.ansiblelint,
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.diagnostics.zsh,

        ----------------------
        --    Formatters    --
        ----------------------
        null_ls.builtins.formatting.erlfmt,
        null_ls.builtins.formatting.just,
        null_ls.builtins.formatting.prettierd,
        null_ls.builtins.formatting.terraform_fmt,
      },
    }
  end,
}
