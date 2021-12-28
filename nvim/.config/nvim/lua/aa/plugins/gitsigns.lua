local present, gitsigns = pcall(require, "gitsigns")
if not present then
	return
end

gitsigns.setup({
	keymaps = {}, -- Do not use the default mappings
	signs = {
		add = { hl = "GitGutterAdd", text = "+" },
		change = { hl = "GitGutterChange", text = "~" },
		delete = { hl = "GitGutterDelete", text = "-" },
		topdelete = { hl = "GitGutterDelete", text = "-" },
		changedelete = { hl = "GitGutterChange", text = "-" },
	}
})
