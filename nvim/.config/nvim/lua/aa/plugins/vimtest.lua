local nnoremap, g = aa.nmap, vim.g

g.VimuxOrientation = "h"
g.VimuxHeight = 30

nnoremap({ "<leader>T", "<cmd>TestNearest<CR>" })
nnoremap({ "<leader>t", "<cmd>TestFile<CR>" })
nnoremap({ "<leader>a", "<cmd>TestSuite<CR>" })
nnoremap({ "<leader>l", "<cmd>TestLast<CR>" })
