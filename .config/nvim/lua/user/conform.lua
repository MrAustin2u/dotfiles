local M = {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  event = { "BufReadPre", "BufNewFile" },
  keys = require("config.keymaps").formatting_mappings(),
  opts = {
    formatter_by_ft = {
      ["*"] = { "codespell" },
      css = { "prettier" },
      graphql = { "prettier" },
      html = { "prettier" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      lua = { "stylua" },
      markdown = { "prettier" },
      python = { "isort", "black" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      yaml = { "prettier" },
    },
    format = {
      timeout_ms = 3000,
      async = false,
      quiet = false,
      lsp_fallback = true,
    },
  },
}

function M.config(_, opts)
  require("conform").setup(opts)
end

return M
