return {
  "nvimtools/none-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
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
        b.diagnostics.yamllint,
        b.diagnostics.zsh,
        -- ESLint diagnostics removed to avoid duplication with ESLint LSP
        -- require("none-ls.diagnostics.eslint_d").with {
        --   condition = function(utils)
        --     return utils.root_has_file { ".eslintrc.js", ".eslintrc.ts", ".eslintrc.json" } -- only enable if root has an eslint file
        --   end,
        -- },
        b.diagnostics.credo.with {
          condition = function(utils)
            return utils.root_has_file { ".credo.exs" } -- only enable if root has a credo file
          end,
        },
        b.diagnostics.commitlint.with {
          condition = function(utils)
            return utils.root_has_file { "commitlint.config.js" }
          end,
        },
      },
    }
  end,
}
