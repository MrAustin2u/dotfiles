return {
  "jose-elias-alvarez/null-ls.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local null_ls = require("null-ls")

    local b = null_ls.builtins

    null_ls.setup({
      sources = {
        ----------------------
        --   Code Actions   --
        ----------------------
        b.code_actions.eslint_d,
        b.code_actions.shellcheck,
        b.code_actions.gomodifytags,

        ----------------------
        --    Diagnostics   --
        ----------------------
        b.diagnostics.actionlint,
        b.diagnostics.codespell,
        b.diagnostics.eslint_d,
        b.diagnostics.rubocop,
        b.diagnostics.shellcheck,
        b.diagnostics.yamllint,
        b.diagnostics.zsh,
        require("plugins.null-ls.commitlint"),

        ----------------------
        --    Formatters    --
        ----------------------
        b.formatting.gofmt,
        b.formatting.goimports,
        b.formatting.pg_format,
        b.formatting.prettierd.with({
          extra_filetypes = { "ruby" },
        }),
        b.formatting.shfmt,
        b.formatting.stylua,
      },
    })
  end,
}
