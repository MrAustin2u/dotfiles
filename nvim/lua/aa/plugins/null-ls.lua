local nls = require("null-ls")
local lsp = require("aa.utils").lsp
local b = nls.builtins

nls.setup({
  debounce = 150,
  save_after_format = false,
  on_attach = lsp.on_attach,
  sources = {
    b.formatting.eslint_d,
    b.code_actions.eslint_d,
    b.formatting.mix,
    b.formatting.prettierd.with({
      filetypes = { "css", "scss", "html", "json", "yaml", "markdown" }
    }),
    b.diagnostics.eslint_d,
    b.code_actions.gitsigns,
    b.formatting.stylua.with({
      extra_args = { "--config-path", vim.fn.expand("~/.config/stylua.toml") },
    }),
  }
})
