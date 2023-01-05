local installer_present, installer = pcall(require, "mason-tool-installer")

if not installer_present then
	vim.notify("Failed to initialize Mason Tool Installer!")
	return
end

local M = {}

M.setup = function()
	installer.setup({

		-- a list of all tools you want to ensure are installed upon
		-- start; they should be the names Mason uses for each tool
		ensure_installed = {
			-- Null LS
			"actionlint",
			"codespell",
			"eslint_d",
			"prettierd",
			"shellcheck",
			"stylua",
			"yamllint",

			-- LSPs

			"bash-language-server",
			"css-lsp",
			"dockerfile-language-server",
			"elixir-ls",
			"elm-language-server",
			"eslint-lsp",
			"gopls",
			"html-lsp",
			"json-lsp",
			"lua-language-server",
			"rust-analyzer",
			"sqlls",
			"tailwindcss-language-server",
			"terraform-ls",
			"typescript-language-server",
			"vim-language-server",
			"yaml-language-server",
		},
	})
end

return M
