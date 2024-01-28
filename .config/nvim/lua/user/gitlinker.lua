local M = { "ruifm/gitlinker.nvim" }

function M.config(_, opts)
	require("gitlinker").setup(opts)
end

return M
