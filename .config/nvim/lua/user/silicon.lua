local M = {
	"narutoxy/silicon.lua",
	dependencies = { "nvim-lua/plenary.nvim" },
}

function M.config()
	require("silicon").setup({
		font = "MonoLisa",
		theme = "tokyonight_moon",
		bgColor = "#636da6",
	})
	require("config.keymaps").silicon_mappings()
end

return M
