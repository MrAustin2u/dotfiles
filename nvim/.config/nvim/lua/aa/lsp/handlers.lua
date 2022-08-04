local api, cmd, lsp = vim.api, vim.cmd, vim.lsp
local tbl_filter, tbl_islist, tbl_isempty = vim.tbl_filter, vim.tbl_islist, vim.tbl_isempty
local M = {}

-- Jump directly to the first available definition every time.
lsp.handlers["textDocument/definition"] = function(_, result)
	if not result or tbl_isempty(result) then
		print("[LSP] Could not find definition")
		return
	end

	if tbl_islist(result) then
		lsp.util.jump_to_location(result[1], "utf-8")
	else
		lsp.util.jump_to_location(result, "utf-8")
	end
end

lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(lsp.handlers["textDocument/publishDiagnostics"], {
	signs = {
		severity_limit = "Error",
	},
	underline = {
		severity_limit = "Warning",
	},
	virtual_text = true,
})

lsp.handlers["window/showMessage"] = require("aa.lsp.show_message")

M.implementation = function()
	local params = lsp.util.make_position_params()

	lsp.buf_request(0, "textDocument/implementation", params, function(err, result, ctx, config)
		local bufnr = ctx.bufnr
		local ft = api.nvim_buf_get_option(bufnr, "filetype")

		-- In go code, I do not like to see any mocks for impls
		if ft == "go" then
			local new_result = tbl_filter(function(v)
				return not string.find(v.uri, "mock_")
			end, result)

			if #new_result > 0 then
				result = new_result
			end
		end

		lsp.handlers["textDocument/implementation"](err, result, ctx, config)
		cmd([[normal! zz]])
	end)
end

return M
