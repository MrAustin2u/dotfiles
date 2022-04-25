local null_ls = require("null-ls")
local b = null_ls.builtins

local M = {}

local sources = {
	b.formatting.trim_whitespace.with({ filetypes = { "*" } }),
	b.code_actions.eslint_d,
	b.code_actions.gitsigns,
	b.diagnostics.credo,
	b.formatting.mix,
	b.formatting.prettier_d_slim.with({
		filetypes = { "css", "scss", "html", "json", "yaml", "markdown" },
	}),
	b.formatting.stylua,
}

M.setup = function(on_attach)
	null_ls.setup({
		sources = sources,
		on_attach = on_attach,
	})
end

return M
