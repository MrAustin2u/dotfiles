return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require "null-ls"

    null_ls.setup {
      sources = {
        -- code actions
        -- linters
        require "none-ls.diagnostics.eslint_d",
        null_ls.builtins.diagnostics.actionlint,
        null_ls.builtins.diagnostics.ansiblelint,
        null_ls.builtins.diagnostics.credo,
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.diagnostics.zsh,
        -- formatters
        null_ls.builtins.formatting.erlfmt,
        null_ls.builtins.formatting.just,
        null_ls.builtins.formatting.prettierd,
        null_ls.builtins.formatting.terraform_fmt,
      },
    }
  end,
}
