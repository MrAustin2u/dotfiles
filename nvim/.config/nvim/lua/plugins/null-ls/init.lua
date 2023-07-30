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
      require("typescript.extensions.null-ls.code-actions"),
      ----------------------
      --    Diagnostics   --
      ----------------------
      b.diagnostics.eslint_d,
      b.diagnostics.yamllint,
      b.diagnostics.zsh,
      require("plugins.null-ls.commitlint"),

      ----------------------
      --    Formatters    --
      ----------------------
      b.formatting.gofmt,
      b.formatting.goimports,
      b.formatting.pg_format,
      b.formatting.prettierd,
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
