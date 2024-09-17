local LSPHELPERS = require "plugins.lsp.helpers"

local M = {}

M.setup = function(opts)
  return {
    nextls = {
      enable = false,
      -- installed via mason
      cmd = "nextls",
      init_options = {
        mix_env = "dev",
        mix_target = "host",
        experimental = {
          completions = {
            enable = true,
          },
        },
      },
      on_attach = function(client, bufnr)
        require("config.keymaps").elixir_mappings()
        LSPHELPERS.on_attach(client, bufnr)
      end,
    },
    credo = { enable = true },
    elixirls = {
      enable = true,
      settings = opts.elixirls.settings {
        dialyzerEnabled = true,
        enableTestLenses = false,
      },
      on_attach = function(client, bufnr)
        require("config.keymaps").elixir_mappings()
        LSPHELPERS.on_attach(client, bufnr)
      end,
    },
  }
end

return M
