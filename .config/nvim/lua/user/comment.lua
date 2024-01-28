local M = {
	"echasnovski/mini.comment",
	event = "VeryLazy",
	dependencies = {
		{
			"JoosepAlviste/nvim-ts-context-commentstring",
			lazy = true,
			opts = {
				enable_autocmd = false,
			},
		},
	},
	opts = {
		options = {
			custom_commentstring = function()
				return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
			end,
		},
	},
}

function M.config(_, opts)
	require("mini.comment").setup(opts)
end

return M
