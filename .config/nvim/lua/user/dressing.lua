local M = { "stevearc/dressing.nvim" }

function M.config()
	require("dressing").setup({
		input = {
			override = function(conf)
				conf.col = -1
				conf.row = 0
				return conf
			end,
		},
	})
end

return M
