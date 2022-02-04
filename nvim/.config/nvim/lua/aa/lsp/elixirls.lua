local M = {}

M = {
	setup = function(on_attach, capabilities)
		local lspconfig = require("lspconfig")
		local path_to_elixirls = vim.fn.expand("~/elixir-ls/release/language_server.sh")

		lspconfig["elixirls"].setup({
			capabilities = capabilities,
			cmd = { path_to_elixirls },
			on_attach = on_attach,
			settings = {
				elixirLS = {
					dialyzerEnabled = true,
					fetchDeps = true,
				},
			},
		})
	end,
}

return M
