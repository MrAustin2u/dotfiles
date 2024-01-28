local M = { "Bekaboo/deadcolumn.nvim" }

function M.config(_, opts)
	require("deadcolumn").setup(opts)
end

return M
