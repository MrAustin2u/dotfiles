return {
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatter_by_ft = {
          ["*"] = { "codespell" },
          css = { "prettier" },
          graphql = { "prettier" },
          html = { "prettier" },
          javascript = { "prettier", "drpint" },
          javascriptreact = { "prettier", "dprint" },
          lua = { "stylua" },
          markdown = { "prettier" },
          python = { "isort", "black" },
          typescript = { "prettier", "dprint" },
          typescriptreact = { "prettier", "drpint" },
          yaml = { "prettier" },
        },
        format_on_save = {
          async = false,
          lsp_fallback = true,
          timeout_ms = 500,
        },
      })

      require("config.keymaps").formatting_mappings()
    end,
  },
}
