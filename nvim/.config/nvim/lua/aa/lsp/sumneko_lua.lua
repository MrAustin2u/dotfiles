USER = vim.fn.expand("$USER")

local sumneko_root_path = ""
local sumneko_binary = ""

sumneko_root_path = "/Users/" .. USER .. "/.config/nvim/lua-language-server"
sumneko_binary = "/Users/" .. USER .. "/opt/homebrew/bin/lua-language-server"

local M = {}

local settings = {
	cmd = { sumneko_binary, "-E", sumneko_root_path .. "/main.lua" },
	settings = {
		Lua = {
			completion = {
				showWord = "Disable",
			},
			runtime = {
				-- Tell the language server which version of Lua you"re using (most likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
				-- Setup your lua path
				path = vim.split(package.path, ";"),
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim", "aa", "global", "use" },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
				},
				preloadFileSize = 500,
				maxPreload = 500,
			},
			telemetry = {
				enable = false,
			},
		},
	},
}

M.setup = function(on_attach, capabilities)
	local luadev = require("lua-dev").setup({
		lspconfig = {
			capabilities = capabilities,
			flags = {
				debounce_text_changes = 150,
			},
			on_attach = on_attach,
			settings = settings,
		},
	})

	require("lspconfig").sumneko_lua.setup(luadev)
end

return M
