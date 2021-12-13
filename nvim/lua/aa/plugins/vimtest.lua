local nmap, g = aa.nnoremap, vim.g

g.VimuxOrientation = "h"
g.VimuxHeight = 30

nmap("<leader>T", "<cmd>TestNearest<CR>")
nmap("<leader>t", "<cmd>TestFile<CR>")
nmap("<leader>a", "<cmd>TestSuite<CR>")
nmap("<leader>l", "<cmd>TestLast<CR>")
