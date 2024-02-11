local M = {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
}

function M.config()
  local lint = require("lint")

  lint.linters_by_ft = {
    ["*"] = { "codespell" },
    elixir = { "credo" },
    javascript = { "eslint" },
    javascriptreact = { "eslint" },
    typescript = { "eslint" },
    typescriptreact = { "eslint" },
    yaml = { "yamllint" },
  }

  local lint_augroup = vim.api.nvim_create_augroup("lint", {
    clear = true,
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = lint_augroup,
    callback = function()
      lint.try_lint()
    end,
  })

  require("config.keymaps").lint_mappings(lint)
end

return M
