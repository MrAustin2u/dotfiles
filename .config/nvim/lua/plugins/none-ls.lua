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
        --    Diagnostics   --
        ----------------------
        null_ls.builtins.diagnostics.actionlint,
        null_ls.builtins.diagnostics.ansiblelint,
        null_ls.builtins.diagnostics.yamllint,
        null_ls.builtins.diagnostics.zsh,
        require("none-ls.diagnostics.eslint_d").with {
          condition = function(utils)
            return utils.root_has_file { ".eslintrc.js", ".eslintrc.ts", ".eslintrc.json" } -- only enable if root has an eslint file
          end,
        },

        ----------------------
        --    Formatters    --
        ----------------------
        null_ls.builtins.formatting.erlfmt,
        null_ls.builtins.formatting.just,
        null_ls.builtins.formatting.prettierd,
        null_ls.builtins.formatting.terraform_fmt,
        null_ls.builtins.formatting.biome.with {
          condition = function(utils)
            return utils.root_has_file { "biome.json" } -- only enable if root has a biome file
          end,
        },
      },
    }
  end,
}
