local M = {
  'nvimtools/none-ls.nvim',
}

function M.config()
  local null_ls = require('null-ls')

  null_ls.setup({
    sources = {
      null_ls.builtins.diagnostics.credo,
      null_ls.builtins.diagnostics.codespell,
      null_ls.builtins.diagnostics.eslint_d,
      null_ls.builtins.diagnostics.yamllint,
      null_ls.builtins.formatting.black,
      null_ls.builtins.formatting.just,
      null_ls.builtins.formatting.prettierd,
      null_ls.builtins.formatting.stylua,
      null_ls.builtins.formatting.terraform_fmt,
      null_ls.builtins.formatting.yamlfix,
    },
  })
end

return M
