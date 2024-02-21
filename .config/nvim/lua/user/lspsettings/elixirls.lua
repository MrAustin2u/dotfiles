return {
  settings = {
    cmd = { vim.fn.expand("~/elixir-ls/scripts/language_server.sh") },
    elixirLS = {
      fetchDeps = false,
      dialyzerEnabled = true,
      dialyzerFormat = "dialyxir_short",
      suggestSpecs = true,
    },
  },
}
