return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = require("conform")

      conform.setup({
        formatter_by_ft = {
          ["*"] = { "codespell" },
          css = { "prettier" },
          graphql = { "prettier" },
          html = { "prettier" },
          javascript = { "drpint" },
          javascriptreact = { "drpint" },
          lua = { "stylua" },
          markdown = { "prettier" },
          python = { "isort", "black" },
          typescript = { "dprint" },
          typescriptreact = { "dprint" },
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
