local null_ls_present, null_ls = pcall(require, "null-ls")
local lsp_format_present, lsp_format = pcall(require, "lsp-format")

if not null_ls_present or not lsp_format_present then
  vim.notify("Failed to set up null-ls and lsp-format")
  return
end

local M = {}

M.setup = function()
  local b = null_ls.builtins

  lsp_format.setup({})

  null_ls.setup({
    sources = {
      ----------------------
      --   Code Actions   --
      ----------------------
      b.code_actions.eslint_d,
      b.code_actions.shellcheck,
      b.code_actions.gomodifytags,

      ----------------------
      --    Diagnostics   --
      ----------------------
      b.diagnostics.actionlint,
      b.diagnostics.codespell,
      b.diagnostics.eslint_d,
      b.diagnostics.rubocop,
      b.diagnostics.shellcheck,
      b.diagnostics.yamllint,
      b.diagnostics.zsh,
      require("plugins.null-ls.commitlint"),

      ----------------------
      --    Formatters    --
      ----------------------
      b.formatting.gofmt,
      b.formatting.goimports,
      b.formatting.pg_format,
      b.formatting.prettierd.with({
        extra_filetypes = { "ruby" },
      }),
      b.formatting.shfmt,
      b.formatting.stylua,
    },
    on_attach = function(client)
      if client.supports_method("textDocument/formatting") then
        lsp_format.on_attach(client)
      end
    end,
  })
end

return M
