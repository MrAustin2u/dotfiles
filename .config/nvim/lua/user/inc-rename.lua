local M = {
	"smjonas/inc-rename.nvim",
	keys = require("config.keymaps").inc_rename(),
}

function M.config()
	require("inc_rename").setup()
end

return M
