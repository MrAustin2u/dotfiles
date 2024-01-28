local M = {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = function(_, opts)
		opts.lsp = {
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true,
			},
			hover = {
				enabled = false,
			},
		}

		opts.routes = {
			{
				filter = {
					event = "msg_show",
					any = {
						{ find = "%d+L, %d+B" },
						{ find = "; after #%d+" },
						{ find = "; before #%d+" },
					},
				},
				view = "mini",
			},
			{
				filter = {
					event = "lsp",
					kind = "progress",
					cond = function(message)
						local title = vim.tbl_get(message.opts, "progress", "title")
						-- skip noisy messages
						return title == "code_action"
					end,
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "notify",
					find = "No information available",
				},
				opts = { skip = true },
			},
		}

		opts.presets = {
			bottom_search = true,
			command_palette = true,
			inc_rename = true,
			long_message_to_split = true,
			lsp_doc_border = false,
		}
	end,
}

function M.config(_, opts)
	require("noice").setup(opts)
end

return M
