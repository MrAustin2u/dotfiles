-- Inside herdr, packs/herdr-navigator.lua owns ctrl+h/j/k/l instead.
if vim.env.HERDR_ENV == "1" or (vim.env.HERDR_PANE_ID or "") ~= "" then
  return
end

vim.pack.add { "https://github.com/christoomey/vim-tmux-navigator" }

vim.keymap.set("n", "<c-h>", "<cmd>TmuxNavigateLeft<cr>")
vim.keymap.set("n", "<c-j>", "<cmd>TmuxNavigateDown<cr>")
vim.keymap.set("n", "<c-k>", "<cmd>TmuxNavigateUp<cr>")
vim.keymap.set("n", "<c-l>", "<cmd>TmuxNavigateRight<cr>")
vim.keymap.set("n", "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>")
