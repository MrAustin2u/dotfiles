require("bufferline").setup({
	options = {
		always_show_bufferline = false,
		separator_style = os.getenv("KITTY_WINDOW_ID") and "slant" or "padded_slant",
		diagnostics = "nvim_lsp",
		custom_filter = function(buf)
			local ignored = { "nnn", "dap-repl" }
			if not vim.tbl_contains(ignored, vim.api.nvim_buf_get_option(buf, "filetype")) then
				return true
			end
		end,
	},
})
