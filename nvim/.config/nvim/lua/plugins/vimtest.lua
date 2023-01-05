vim.g.VimuxOrientation = "h"
vim.g.VimuxHeight = 30

vim.keymap.set("n", "<leader>T", "<cmd>TestNearest<CR>", {})
vim.keymap.set("n", "<leader>t", "<cmd>TestFile<CR>", {})
vim.keymap.set("n", "<leader>a", "<cmd>TestSuite<CR>", {})
vim.keymap.set("n", "<leader>l", "<cmd>TestLast<CR>", {})
