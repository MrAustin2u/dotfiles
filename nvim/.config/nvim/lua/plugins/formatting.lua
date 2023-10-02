local present, conform = pcall(require, "conform")

if not present then
  return
end

local M = {}

M.setup = function()
  conform.setup({
    formatter_by_ft = {
      css = { "prettier" },
      graphql = { "prettier" },
      html = { "prettier" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      lua = { "stylua" },
      markdown = { "prettier" },
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      yaml = { "prettier" },
      python = { "isort", "black" },
    },
    format_on_save = {
      async = false,
      lsp_fallback = true,
      timeout_ms = 500,
    },
  })

  require("keymaps").formatting_mappings()
end

return M
