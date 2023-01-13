---@diagnostic disable: redundant-parameter
local present, gitsigns = pcall(require, "gitsigns")

if not present then
	return
end

local M = {}

M.setup = function()
	gitsigns.setup({
		signs = {
			add = { hl = "GitGutterAdd", text = "+" },
			change = { hl = "GitGutterChange", text = "~" },
			delete = { hl = "GitGutterDelete", text = "-" },
			topdelete = { hl = "GitGutterDelete", text = "-" },
			changedelete = { hl = "GitGutterChange", text = "-" },
		},
		on_attach = function(bufnr)
			require("core.mappings").gitsigns_mappings(gitsigns, bufnr)

			vim.cmd("hi SignColumn guibg=None")
		end,
	})
end

return M
