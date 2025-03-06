return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup {
      signs = {
        add = {
          text = aa.icons.ui.BoldLineLeft,
        },
        change = {
          text = aa.icons.ui.BoldLineDashedMiddle,
        },
        delete = {
          text = aa.icons.ui.TriangleMediumArrowRight,
        },
        topdelete = {
          text = aa.icons.ui.TriangleMediumArrowRight,
        },
        changedelete = {
          text = aa.icons.ui.BoldLineLeft,
        },
        untracked = {
          text = aa.icons.ui.BoldLineLeft,
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
        map("n", "<C-b>", function() gs.blame_line({ full = true }) end, "Blame Line")
        map({ 'n', 'v' }, '<leader>ghs', ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>gbr", gs.reset_buffer, "Reset Buffer")
        map("n", "]h", function()
            if vim.wo.diff then
              vim.cmd.normal({ ']h', bang = true })
            else
              gs.nav_hunk('next')
            end
          end,
          "Next Hunk")
        map("n", "[h", function()
            if vim.wo.diff then
              vim.cmd.normal({ '[h', bang = true })
            else
              gs.nav_hunk('prev')
            end
          end,
          "Previous Hunk")
      end,
    }
  end,
}
