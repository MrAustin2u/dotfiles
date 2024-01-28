local M = {
	"tzachar/local-highlight.nvim",
}

function M.config()
	vim.cmd([[hi TSDefinitionUsage guibg=#565f89]])

	require("local-highlight").setup()
end

return M
