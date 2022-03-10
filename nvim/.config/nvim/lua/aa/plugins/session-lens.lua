require("telescope").load_extension("session-lens")

require("session-lens").setup({
	path_display = { "shorten" },
	theme_conf = { border = true },
	previewer = true,
	prompt_title = "ASH SESSIONS",
})
