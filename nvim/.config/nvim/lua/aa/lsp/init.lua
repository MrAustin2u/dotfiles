local utils = require("aa.utils")
local lspconfig = require("lspconfig")
local api = vim.api

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

--- This overwrites the diagnostic show/set_signs function to replace it with a custom function
--- that restricts nvim's diagnostic signs to only the singe most severe one per line
local ns = api.nvim_create_namespace("severe-diagnostics")
local show = vim.diagnostic.show
local function display_signs(bufnr)
	-- Get all diagnostics from the current buffer
	local diagnostics = vim.diagnostic.get(bufnr)
	local filtered = utils.lsp.filter_diagnostics(diagnostics, bufnr)
	show(ns, bufnr, filtered, {
		virtual_text = false,
		underline = false,
		signs = true,
	})
end

function vim.diagnostic.show(namespace, bufnr, ...)
	show(namespace, bufnr, ...)
	display_signs(bufnr)
end

local on_attach = require("aa.utils").lsp.on_attach
local capabilities = require("aa.utils").lsp.capabilities()

for _, server in
	ipairs({
		"cssls",
		"eslint",
		"elixirls",
		"graphql",
		-- "html",
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
