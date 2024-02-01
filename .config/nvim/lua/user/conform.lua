local M = {
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  event = { "BufReadPre", "BufNewFile" },
  keys = require("config.keymaps").formatting_mappings(),
  opts = {
    formatter_by_ft = {
      ["*"] = { "codespell" },
      css = { "prettierd" },
      graphql = { "prettierd" },
      html = { "prettierd" },
      javascript = { "prettierd" },
      javascriptreact = { "prettierd" },
      lua = { "stylua" },
      markdown = { "prettierd" },
      python = { "isort", "black" },
      typescript = { "prettierd" },
      typescriptreact = { "prettierd" },
      yaml = { "prettierd" },
    },
    format_on_save = {
      lsp_fallback = true,
      timeout_ms = 500,
    },
  },
}

function M.config(_, opts)
  require("conform").setup(opts)
end

return M
