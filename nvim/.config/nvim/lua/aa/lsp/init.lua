local utils = require("aa.utils")
local lspconfig = require("lspconfig")

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
	underline = true,
	virtual_text = false,
	signs = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		focusable = false,
		header = "",
		prefix = "",
		severity_sort = true,
		source = "if_many",
		style = "minimal",
	},
})

local on_attach = require("aa.utils").lsp.on_attach
local capabilities = require("aa.utils").lsp.capabilities()

for _, server in
	ipairs({
		"cssls",
		"eslint",
		"elixirls",
		"graphql",
		"html",
		"tailwindcss",
		"jsonls",
		"null-ls",
		"sumneko_lua",
		"tsserver",
	})
do
	if require("aa.lsp." .. server) then
		require("aa.lsp." .. server).setup(on_attach, capabilities)
	else
		lspconfig[server].setup(utils.lsp.defaults())
	end
end

-- suppress lspconfig messages
local notify = vim.notify
vim.notify = function(msg, ...)
	if msg:match("%[lspconfig%]") then
		return
	end

	notify(msg, ...)
end
