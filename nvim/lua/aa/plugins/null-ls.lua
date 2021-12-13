local nls = require("null-ls")
local b = nls.builtins
local M = {}

M.setup = function()
  nls.config({
    debounce = 150,
    save_after_format = false,
    sources = {
      b.formatting.eslint_d,
      b.code_actions.eslint_d,
      -- b.formatting.mix,
      b.formatting.prettierd.with({
        filetypes = { "css", "scss", "html", "json", "yaml", "markdown" }
      }),
      b.diagnostics.eslint_d,
      b.code_actions.gitsigns,
      b.formatting.stylua.with({
        condition = function(util)
          return aa.executable("stylua") and util.root_has_file("stylua.toml")
        end,
      }),
    }
  })
end

M.has_formatter = function(ft)
  local sources = require("null-ls.sources")
  local available = sources.get_available(ft, "NULL_LS_FORMATTING")
  return #available > 0
end

return M
