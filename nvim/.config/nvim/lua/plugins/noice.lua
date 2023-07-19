local present, noice = pcall(require, "noice")

if not present then
  return
end

local M = {}

M.setup = function()
  noice.setup({
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    views = {
      cmdline_popup = {
        position = {
          row = 1,
          col = "50%",
        },
      },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
    routes = {
      {
        view = "mini",
        filter = {
          event = "msg_show",
          kind = "",
          find = "written",
        },
        opts = {},
      },
      -- hide the annoying code_action notifications from null ls
      {
        filter = {
          event = "lsp",
          kind = "progress",
          cond = function(message)
            local title = vim.tbl_get(message.opts, "progress", "title")
            local client = vim.tbl_get(message.opts, "progress", "client")

            -- skip null-ls noisy messages
            return client == "null-ls" and title == "code_action"
          end,
        },
        opts = { skip = true },
      },
    },
  })

  -- require("keymaps").noice_mappings(noice)
end

return M
