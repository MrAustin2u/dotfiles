local on_attach = require("aa.utils").lsp.on_attach
local null_ls = require("null-ls")
local b = null_ls.builtins

local sources = {
  b.code_actions.eslint_d,
  b.diagnostics.credo,
  b.formatting.mix,
  b.formatting.prettier_d_slim,
  b.formatting.stylua,
}

null_ls.setup({
  sources = sources,
  on_attach = on_attach,
})
