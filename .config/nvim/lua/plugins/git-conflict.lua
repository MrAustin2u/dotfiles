return {
  "akinsho/git-conflict.nvim",
  version = "*",
  config = function()
    require("git-conflict").setup {
      default_mappings = {
        ours = "c",
        theirs = "i",
        none = "0",
        both = "2",
        next = "n",
        prev = "p",
      },
    }

    vim.api.nvim_create_autocmd("User", {
      pattern = "GitConflictDetected",
      callback = function()
        vim.notify("Conflict detected in " .. vim.fn.expand "<afile>")
        vim.keymap.set("n", "<leader>co", ":GitConflictListQf<CR>", { desc = "Open conflicts" })
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "GitConflictResolved",
      callback = function()
        vim.notify "All conflicts were resolved"
      end,
    })
  end,
}
