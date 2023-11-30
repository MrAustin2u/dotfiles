return {
  {
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
        go = { "goimports", "gofumpt" },
      },
    },
  },
}
