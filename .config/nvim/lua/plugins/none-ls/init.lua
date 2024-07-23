return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "williamboman/mason.nvim",
  },
  config = function()
    local null_ls = require "null-ls"
    local b = null_ls.builtins

    null_ls.setup {
      sources = {
        ----------------------
        --   Code Actions   --
        ----------------------
        b.code_actions.gomodifytags,
        -- Injects code actions for Git operations at the current cursor position (stage / preview / reset hunks, blame, etc.).
        b.code_actions.gitsigns,

        ----------------------
        --    Diagnostics   --
        ----------------------
        b.diagnostics.actionlint,
        b.diagnostics.ansiblelint,
        b.diagnostics.codespell.with {
          disabled_filetypes = { "neo-tree" },
        },

        b.diagnostics.yamllint,
        b.diagnostics.zsh,
      },
    }
  end,
}
