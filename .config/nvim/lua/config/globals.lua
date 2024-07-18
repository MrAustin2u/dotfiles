local keymap_opts = { noremap = true, silent = true }

_G.I = vim.inspect
_G.fmt = string.format
_G.dbg = function(thing)
  vim.notify(I(thing))
end

function _G.set_terminal_keymaps()
  vim.api.nvim_buf_set_keymap(0, "t", "<m-h>", [[<C-\><C-n><C-W>h]], keymap_opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<m-j>", [[<C-\><C-n><C-W>j]], keymap_opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<m-k>", [[<C-\><C-n><C-W>k]], keymap_opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<m-l>", [[<C-\><C-n><C-W>l]], keymap_opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<esc>", "<esc>", { noremap = true, silent = true, nowait = true })
end
