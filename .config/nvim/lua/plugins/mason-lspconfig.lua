---@type LazySpec
return {
  "mason-org/mason-lspconfig.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason-org/mason.nvim",
    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "saghen/blink.cmp",
      },
    },
    { "b0o/schemastore.nvim", lazy = true },
  },
  opts = {
    automatic_enable = true,
  },
  config = function(_self, opts)
    require("config.lsp").setup()
    require("mason-lspconfig").setup(opts)
  end,
}
