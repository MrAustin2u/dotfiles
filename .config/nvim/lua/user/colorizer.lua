local M = {
	"norcalli/nvim-colorizer.lua",
	event = "VeryLazy",
	opts = {
		"*",
		"!lazy",
	},
}

function M.config(_, opts)
	require("colorizer").setup(opts)
end

return M
