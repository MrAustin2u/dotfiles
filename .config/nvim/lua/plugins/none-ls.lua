return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require "null-ls"

    null_ls.setup {
      sources = {
        ----------------------
        --   Code Actions   --
        ----------------------
        null_ls.builtins.code_actions.gomodifytags,
        -- Injects code actions for Git operations at the current cursor position (stage / preview / reset hunks, blame, etc.).
        null_ls.builtins.code_actions.gitsigns,

        ----------------------
        --    Diagnostics   --
        ----------------------
        null_ls.builtins.diagnostics.actionlint,
        null_ls.builtins.diagnostics.ansiblelint,
        null_ls.builtins.diagnostics.credo,
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.diagnostics.zsh,
        require("none-ls.diagnostics.eslint_d").with {
          condition = function(utils)
            return utils.root_has_file { ".eslintrc.js", ".eslintrc.ts", ".eslintrc.json" } -- only enable if root has an eslint file
          end,
        },
        null_ls.builtins.diagnostics.credo.with {
          condition = function(utils)
            return utils.root_has_file { ".credo.exs" } -- only enable if root has a credo file
          end,
        },
        null_ls.builtins.diagnostics.commitlint.with {
          condition = function(utils)
            return utils.root_has_file { "commitlint.config.js" }
          end,
        },
      },
    }
  end,
}
