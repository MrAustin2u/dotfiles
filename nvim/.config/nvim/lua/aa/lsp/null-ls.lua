local null_ls = require("null-ls")
local b = null_ls.builtins

local M = {}

local sources = {
    b.formatting.eslint_d,
    b.code_actions.eslint_d,
    b.diagnostics.eslint_d,
    b.formatting.mix,
    b.diagnostics.credo,
    b.formatting.prettierd.with({
      filetypes = { "css", "scss", "html", "json", "yaml", "markdown" }
    }),
    b.code_actions.gitsigns,
    b.formatting.stylua.with({
      condition = function(utils)
          return utils.root_has_file("stylua.toml")
      end,
    })
}

M.setup = function(on_attach)
  null_ls.setup({
    --debug = true,
    sources = sources,
    on_attach = on_attach,
  })
end

return M
