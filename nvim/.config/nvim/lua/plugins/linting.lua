return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        ["*"] = { "codespell" },
        elixir = { "credo" },
        -- javascript = { "eslint_d" },
        -- javascriptreact = { "eslint_d" },
        python = { "pylint" },
        -- typescript = { "eslint_d" },
        -- typescriptreact = { "eslint_d" },
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
    end,
  },
}
