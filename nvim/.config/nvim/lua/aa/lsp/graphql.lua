local M = {
	setup = function(on_attach, capabilities)
		local lspconfig = require("lspconfig")

		lspconfig["graphql"].setup({
			on_attach = on_attach,
			capabilities = capabilities,
		})
	end,
}

return M
