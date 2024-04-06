local M = {
  "elixir-tools/elixir-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
}

function M.config()
  local elixir = require("elixir")
  local elixirls = require("elixir.elixirls")
  local keymaps = require("config.keymaps")
  local lsp_on_attach = require("user.lsp").on_attach

  elixir.setup({
    nextls = { enable = false },
    credo = { enable = true },
    elixirls = {
      tag = "v0.20.0",
      enable = true,
      settings = elixirls.settings({
        dialyzerEnabled = true,
        enableTestLenses = false,
      }),
      on_attach = function(client, bufnr)
        keymaps.elixir_mappings()
        lsp_on_attach(client, bufnr)
      end,
    },
  })
end

return M
