return {
  'jose-elias-alvarez/null-ls.nvim',
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "mason.nvim" },
  config = function()
    local null_ls = require('null-ls')

    null_ls.setup({
      sources = {
        -- null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.diagnostics.credo.with({
          -- run credo in strict mode even if strict mode is not enabled in
          -- .credo.exs
          extra_args = { '--strict' },
          -- only register credo source if it is installed in the current project
          condition = function(_utils)
            local cmd = { 'rg', ':credo', 'mix.exs' }
            local credo_installed = ('' == vim.fn.system(cmd))
            return not credo_installed
          end,
        }),
        null_ls.builtins.diagnostics.credo.with({
          condition = function(utils)
            return utils.root_has_file('.credo.exs')
          end
        }),
        null_ls.builtins.formatting.just,
        null_ls.builtins.formatting.terraform_fmt
      },
    })
  end
}
