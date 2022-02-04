local M = {
	setup = function(on_attach, capabilities)
		local lspconfig = require("lspconfig")

		lspconfig["html"].setup({
			on_attach = on_attach,
			capabilities = capabilities,
			cmd = { "vscode-html-language-server", "--stdio" },
			filetypes = { "html", "javascriptreact", "typescriptreact", "eelixir", "heex" },
			init_options = {
				configurationSection = { "html", "css", "javascript", "eelixir", "heex" },
				embeddedLanguages = {
					css = true,
					javascript = true,
					elixir = true,
					heex = true,
				},
			},
		})
	end,
}

return M
