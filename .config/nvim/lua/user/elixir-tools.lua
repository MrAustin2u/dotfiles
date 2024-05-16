local M = {
  'elixir-tools/elixir-tools.nvim',
  version = '*',
  event = { 'BufReadPre', 'BufNewFile' },
}

function M.config()
  local elixir = require 'elixir'
  local elixirls = require 'elixir.elixirls'

  elixir.setup {
    nextls = { enable = false },
    credo = { enable = true },
    elixirls = {
      enable = true,
      settings = elixirls.settings {
        dialyzerEnabled = true,
        enableTestLenses = false,
      },
      on_attach = function(client, bufnr)
        require("config.keymaps").elixir_mappings()
        require('user.lsp').on_attach(client, bufnr)
      end,
    },
  }
end

return M
