local buf_map = aa.buf_map

local ts_utils_settings = {
	debug = false,
	import_all_scan_buffers = 100,
	update_imports_on_move = true,
	-- filter diagnostics
	-- {
	--    80001 - require modules
	--    6133 - import is declared but never used
	--    2582 - cannot find name {describe, test}
	--    2304 - cannot find name {expect, beforeEach, afterEach}
	--    2503 - cannot find name {jest}
	-- }
	filter_out_diagnostics_by_code = { 80001, 2582, 2304, 2503 },

	-- linting
	eslint_enable_code_actions = true,
	eslint_enable_disable_comments = true,
	eslint_bin = "eslint_d",
	eslint_enable_diagnostics = true,
	eslint_opts = {},

	-- formatting
	enable_formatting = false,
	formatter = "prettierd",
	formatter_opts = {},

	-- inlay hints
	auto_inlay_hints = true,
	inlay_hints_highlight = "Comment",
}

local M = {}
M.setup = function(on_attach, capabilities)
	local lspconfig = require("lspconfig")
	local ts_utils = require("nvim-lsp-ts-utils")

	lspconfig["tsserver"].setup({
		root_dir = lspconfig.util.root_pattern("package.json"),
		init_options = ts_utils.init_options,
		on_attach = function(client, bufnr)
			on_attach(client, bufnr)

			ts_utils.setup(ts_utils_settings)
			ts_utils.setup_client(client)

			buf_map(bufnr, "n", "gs", ":TSLspOrganize<CR>")
			buf_map(bufnr, "n", "gI", ":TSLspRenameFile<CR>")
			buf_map(bufnr, "n", "go", ":TSLspImportAll<CR>")
		end,
		flags = {
			debounce_text_changes = 150,
		},
		capabilities = capabilities,
	})
end

return M
