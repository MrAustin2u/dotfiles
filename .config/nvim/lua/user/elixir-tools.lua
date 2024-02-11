local M = {
  "elixir-tools/elixir-tools.nvim",
  version = "*",
  dev = false,
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "mhanberg/workspace-folders.nvim",
  },
}

function M.config(_, _)
  local elixir = require("elixir")
  local elixirls = require("elixir.elixirls")
  local on_attach = require("user.lspconfig").on_attach

  elixir.setup({
    nextls = { enable = false },
    credo = { enable = false },
    elixirls = {
      enable = true,
      tag = "v0.16.0",
      settings = elixirls.settings({
        dialyzerEnabled = true,
        fetchDeps = false,
        enableTestLenses = true,
        suggestSpecs = false,
      }),
      on_attach = function(client, bufnr)
        require("config.keymaps").elixir_mappings()
        on_attach(client, bufnr)
      end,
    },
  })
end

return M
