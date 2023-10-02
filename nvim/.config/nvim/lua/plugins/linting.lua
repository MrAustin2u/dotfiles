local present, lint = pcall(require, "lint")

if not present then
  return
end

local M = {}

M.setup = function()
  lint.linters_by_ft = {
    javascript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    lua = { "yamllint" },
    typescript = { "eslint_d" },
    typescriptreact = { "eslint_d" },
    yaml = { "yamllint" },
    python = { "pylint" }
  }

  local lint_augroup = vim.api.nvim_create_augroup("lint", {
    clear = true
  })

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = lint_augroup,
    callback = function()
      lint.try_lint()
    end
  })

  require("keymaps").lint_mappings(lint)
end

return M
