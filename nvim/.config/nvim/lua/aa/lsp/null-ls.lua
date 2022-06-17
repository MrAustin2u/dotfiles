local on_attach = require("aa.utils").lsp.on_attach
local null_ls = require("null-ls")
local b = null_ls.builtins

local sources = {
  -- code actions
  b.code_actions.eslint_d,
  -- diagnostics
  b.diagnostics.credo,
  -- formatting
  b.formatting.trim_whitespace.with({ filetypes = { "*" } }),
  b.formatting.mix,
  b.formatting.prettier_d_slim,
  b.formatting.stylua,
}

null_ls.setup({
  sources = sources,
  on_attach = on_attach,
})
