local Util = require("config.util")

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

-- ================================
-- # Misc
-- ================================

-- command
map("n", ";", ":")

-- Sort
map("v", "ts", ":sort<CR>", { desc = "Text sort" })

-- save file
map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- save and source config files
map({ "i", "v", "n", "s" }, "<C-x>", function()
  if vim.bo.filetype == "vim" then
    vim.cmd("silent! write")
    vim.cmd("source %")
    vim.api.nvim_echo({ { "Saving and sourcing vim file..." } }, true, {})
  elseif vim.bo.filetype == "lua" then
    vim.cmd("silent! write")
    vim.cmd("luafile %")
    vim.api.nvim_echo({ { "Saving and sourcing lua file..." } }, true, {})
  end
end, { desc = "Save and source config files" })

-- lazy
map("n", "<leader>l", "<cmd>:Lazy<cr>", { desc = "Lazy" })

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- toggle options
map("n", "<leader>uf", require("lazyvim.plugins.lsp.format").toggle, { desc = "Toggle format on Save" })
map("n", "<leader>us", function()
  Util.toggle("spell")
end, { desc = "Toggle Spelling" })
map("n", "<leader>uw", function()
  Util.toggle("wrap")
end, { desc = "Toggle Word Wrap" })
map("n", "<leader>ul", function()
  Util.toggle("relativenumber", true)
  Util.toggle("number")
end, { desc = "Toggle Line Numbers" })
map("n", "<leader>ud", Util.toggle_diagnostics, { desc = "Toggle Diagnostics" })
local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
map("n", "<leader>uc", function()
  Util.toggle("conceallevel", false, { 0, conceallevel })
end, { desc = "Toggle Conceal" })

-- lazygit
map("n", "<leader>gg", function()
  Util.float_term({ "lazygit" }, { cwd = Util.get_root() })
end, { desc = "Lazygit (root dir)" })
map("n", "<leader>gG", function()
  Util.float_term({ "lazygit" })
end, { desc = "Lazygit (cwd)" })

-- buffers
if Util.has("bufferline.nvim") then
  map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
  map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
  map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
  map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
else
  map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
  map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
  map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
  map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
end

-- floating terminal
map("n", "<leader>ft", function()
  Util.float_term()
end, { desc = "Terminal (cwd)" })
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })

-- ================================
-- # Copy, Paste, Movements, Etc..
-- ================================

-- copy to end of line
map("n", "Y", "y$", { desc = "Copy to end of line" })
-- copy to system clipboard
map("v", "gy", '"+y', { desc = "Copy to system clipboard (visual mode)" })
-- copy entire file
map("n", "<C-g>y", "ggyG", { desc = "Copy entire file" })
-- copy entire file to system clipboard
map("n", "<C-g>y", 'gg"+yG', { desc = "Copy entire file" })

-- better up/down
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

map("n", "<C-g>y", "ggyG", { desc = "Copy entire file" })
map("n", "<C-g>Y", 'gg"+yG', { desc = "Copy entire file to system clipboard" })

map("n", "<C-p>", function()
  vim.cmd("let @+ = expand('%')")
end, { desc = "Copy relative path" })

-- buffers
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)

-- windows
map("n", "<leader>ww", "<C-W>p", { desc = "Other window" })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below" })
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right" })
map("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
map("n", "<leader>|", "<C-W>v", { desc = "Split window right" })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- highlights under cursor
if vim.fn.has("nvim-0.9.0") == 1 then
  map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
end
