return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
  },
  config = function()
    local null_ls = require "null-ls"

    null_ls.setup {
      sources = {
        -- diagnostics
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
        null_ls.builtins.diagnostics.terraform_validate,
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.diagnostics.zsh,
      },
    }
  end,
}
