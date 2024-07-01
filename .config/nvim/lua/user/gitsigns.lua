local M = {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
}

function M.config(_, _)
  local icons = require("config.icons")

  require("gitsigns").setup({
    signs = {
      add = {
        text = icons.ui.BoldLineLeft,
      },
      change = {
        text = icons.ui.BoldLineDashedMiddle,
      },
      delete = {
        text = icons.ui.TriangleMediumArrowRight,
      },
      topdelete = {
        text = icons.ui.TriangleMediumArrowRight,
      },
      changedelete = {
        text = icons.ui.BoldLineLeft
      },
      untracked = {
        text = icons.ui.BoldLineLeft
      },
    },
    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },
    attach_to_untracked = true,
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
    update_debounce = 200,
    max_file_length = 40000,
    preview_config = {
      border = "rounded",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
      end

      -- stylua: ignore start
      map({ "n", "v" }, "<leader>gh", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
      map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
      map("n", "]h", gs.next_hunk, "Next Hunk")
      map("n", "[h", gs.next_hunk, "Previous Hunk")
      map("n", "<leader>gl", gs.toggle_current_line_blame, "Blame Line")
      map("n", "<leader>gL", function() gs.blame_line({ full = true }) end, "Blame Line")
    end,
  })
end

return M
