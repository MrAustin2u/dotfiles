return {
  "jose-elias-alvarez/null-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "mason.nvim",
  },
  config = function()
    local null_ls = require("null-ls")

    local b = null_ls.builtins

    null_ls.setup({
      root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
      sources = {
        ----------------------
        --   Code Actions   --
        ----------------------
        -- b.code_actions.eslint_d,
        b.code_actions.shellcheck,
        b.code_actions.gomodifytags,
        require("typescript.extensions.null-ls.code-actions"),

        ----------------------
        --    Diagnostics   --
        ----------------------
        b.diagnostics.actionlint,
        -- b.diagnostics.codespell,
        b.diagnostics.eslint_d,
        b.diagnostics.rubocop,
        b.diagnostics.shellcheck,
        b.diagnostics.yamllint,
        b.diagnostics.zsh,
        b.diagnostics.credo.with({
          condition = function(utils)
            return utils.root_has_file(".credo.exs")
          end,
        }),

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
