return {
  'jose-elias-alvarez/null-ls.nvim',
  config = function()
    local null_ls = require('null-ls')

    null_ls.setup({
      sources = {
        null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.formatting.prettier,
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
        null_ls.builtins.diagnostics.credo.with {
          -- run credo in strict mode even if strict mode is not enabled in
          -- .credo.exs
          extra_args = { '--strict' },
          -- only register credo source if it is installed in the current project
          condition = function(_utils)
            local cmd = { 'rg', ':credo', 'mix.exs' }
            local credo_installed = ('' == vim.fn.system(cmd))
            return not credo_installed
          end,
        },
        -- Doesn't work for heex files
        -- null_ls.builtins.formatting.mix.with {
        --   extra_filetypes = { 'eelixir', 'heex' },
        --   args = { 'format', '-' },
        --   extra_args = function(_params)
        --     local version_output = vim.fn.system 'elixir -v'
        --     local minor_version = vim.fn.matchlist(version_output, 'Elixir \\d.\\(\\d\\+\\)')[2]
        --
        --     local extra_args = {}
        --
        --     -- tells the formatter the filename for the code passed to it via stdin.
        --     -- This allows formatting heex files correctly. Only available for
        --     -- Elixir >= 1.14
        --     if tonumber(minor_version, 10) >= 14 then
        --       extra_args = { '--stdin-filename', '$FILENAME' }
        --     end
        --
        --     return extra_args
        --   end,
        -- },
        null_ls.builtins.formatting.just,
        null_ls.builtins.formatting.terraform_fmt
      },
    })
  end
}
