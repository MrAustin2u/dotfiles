local M = {
  "elixir-tools/elixir-tools.nvim",
  version = "*",
  dev = false,
  event = { "BufReadPre", "BufNewFile" },
  keys = require("config.keymaps").elixir_mappings(),
  dependencies = { "nvim-lua/plenary.nvim" },
}

function M.config(_, _)
  local elixir = require("elixir")
  local elixirls = require("elixir.elixirls")
  local on_attach = require("user.lspconfig").on_attach

  elixir.setup({
    elixirls = {
      on_attach = on_attach,
      tag = "v0.16.0",
      settings = elixirls.settings({
        dialyzerEnabled = true,
        fetchDeps = false,
        enableTestLenses = true,
        suggestSpecs = false,
      }),
    },
  })
end

return M
