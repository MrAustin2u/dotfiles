vim.pack.add { "https://github.com/sQVe/sort.nvim" }
require("sort").setup()

vim.keymap.set("v", "go", ":Sort<CR>", { desc = "Order (sort lines/line params)" })
vim.keymap.set("n", "goi'", "vi':Sort<CR>", { desc = "Order in [']" })
vim.keymap.set("n", "goi(", "vi(:Sort<CR>", { desc = "Order in (" })
vim.keymap.set("n", "goi[", "vi[:Sort<CR>", { desc = "Order in [" })
vim.keymap.set("n", "goip", "vip:Sort<CR>", { desc = "Order in [p]aragraph" })
vim.keymap.set("n", "goi{", "vi{:Sort<CR>", { desc = "Order in {" })
vim.keymap.set("n", 'goi"', 'vi":Sort<CR>', { desc = 'Order in ["]' })
