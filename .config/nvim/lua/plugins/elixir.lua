local LSPHELPERS = require "plugins.lsp.helpers"

return {
  "elixir-tools/elixir-tools.nvim",
  version = "*",
  ft = { "elixir", "heex", "eelixir" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local elixir = require "elixir"
    local elixirls = require "elixir.elixirls"

    elixir.setup {
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
        settings = elixirls.settings {
          dialyzerEnabled = true,
          enableTestLenses = false,
        },
        on_attach = function(client, bufnr)
          require("config.keymaps").elixir_mappings()
          LSPHELPERS.on_attach(client, bufnr)
        end,
      },
    }
  end,
}
