-- ==================================
-- # Convenience
-- ===================================

vim.keymap.set("n", ";", ":", { silent = false })
vim.keymap.set("n", "<leader>q", "<cmd>q!<CR>", {})

-- ==================================
-- # Splits
-- ===================================

-- Navigation
vim.keymap.set("n", "<C-h>", "<C-W>h", {})
vim.keymap.set("n", "<C-j>", "<C-W>j", {})
vim.keymap.set("n", "<C-k>", "<C-W>k", {})
vim.keymap.set("n", "<C-l>", "<C-W>l", {})

-- Resize
vim.keymap.set("n", "<M-Left>", ":vertical resize +3<CR>", { silent = true })
vim.keymap.set("n", "<M-Right>", ":vertical resize -3<CR>", { silent = true })
vim.keymap.set("n", "<M-Up>", ":resize -3<CR>", { silent = true })
vim.keymap.set("n", "<M-Down>", ":resize +3<CR>", { silent = true })

-- ==================================
-- # Save and source files
-- ===================================

-- save and execute vim/lua file
vim.keymap.set("n", "<leader>x", function()
  if vim.bo.filetype == "vim" then
    vim.cmd("silent! write")
    vim.cmd("source %")
    vim.api.nvim_echo({ { "Saving and sourcing vim file..." } }, true, {})
  elseif vim.bo.filetype == "lua" then
    vim.cmd("silent! write")
    vim.cmd("luafile %")
    vim.api.nvim_echo({ { "Saving and sourcing lua file..." } }, true, {})
  end
end)
vim.keymap.set("n", "<leader>s", "<cmd>w<CR>", {})

-- ===================================
-- # Nvim-Tree
-- ===================================

vim.keymap.set("n", "nf", "<cmd>NvimTreeFindFile<CR>", {})
vim.keymap.set("n", "nc", "<cmd>NvimTreeClose<CR>", {})
vim.keymap.set("n", "nr", "<cmd>NvimTreeRefresh<CR>", {})

-- ===================================
-- # Telescope
-- ===================================

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>gr", builtin.lsp_references, {})
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fg", function()
  builtin.git_files({ hidden = true })
end)
vim.keymap.set("n", "<leader>fs", builtin.live_grep, {})
vim.keymap.set("n", "<leader>ps", function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set("n", "<leader>km", builtin.keymaps, {})

-- ================================
-- # File Jumps
-- ================================

-- Autocenter file jumps
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
-- ================================
-- # Learn how to spell stupid!
-- ================================

vim.keymap.set("n", "<leader>z", "<cmd>setlocal spell!<CR>", {})
vim.keymap.set("n", "<leader>=", "z=", {})
vim.keymap.set("n", "<leader>]", "]s", {})

-- ================================
-- # A Tab bit much
-- ================================

-- Go to tab by number
vim.keymap.set("n", "<leader>1", "1gt", {})
vim.keymap.set("n", "<leader>2", "2gt", {})
vim.keymap.set("n", "<leader>3", "3gt", {})
vim.keymap.set("n", "<leader>4", "4gt", {})
vim.keymap.set("n", "<leader>5", "5gt", {})
vim.keymap.set("n", "<leader>6", "6gt", {})
vim.keymap.set("n", "<leader>7", "7gt", {})
vim.keymap.set("n", "<leader>8", "8gt", {})
vim.keymap.set("n", "<leader>9", "9gt", {})

vim.keymap.set("n", "<leader>0", "<cmd>tablast<CR>", {})

vim.keymap.set("n", "<C-Left>", "<cmd>tabprevious<CR>", {})
vim.keymap.set("n", "<C-Right>", "<cmd>tabnext<CR>", {})

-- ================================
-- # Sort
-- ================================
vim.keymap.set("n", "<leader>S", "<cmd>!sort<CR>", {})

-- ================================
-- # Plug{Packer}
-- ================================

vim.keymap.set("n", "<leader>pi", "<cmd>PackerInstall<CR>", {})
vim.keymap.set("n", "<leader>pu", "<cmd>PackerUpdate<CR>", {})
vim.keymap.set("n", "<leader>pc", "<cmd>PackerClean<CR>", {})

-- ================================
-- # Git
-- ================================
local gitsigns = require("gitsigns")
vim.keymap.set("n", "<leader>gb", function()
  gitsigns.blame_line({ full = true })
end)

-- ================================
-- # Misc
-- ================================

-- Shut up already
vim.keymap.set("n", "<Leader>,", "<cmd>noh<CR>", {})

vim.keymap.set("n", "<leader>a", "ggVG", {})

-- Yanking and pasting from system clipboard
vim.keymap.set("v", "Y", [["+y]], {})
vim.keymap.set("n", "<Leader>y", '"*y', {})
vim.keymap.set("n", "<Leader>Y", '"*Y', {})
vim.keymap.set("v", "<Leader>y", '"*y', {})
vim.keymap.set("n", "<Leader>p", '"*p', {})
vim.keymap.set("n", "<Leader>P", '"*P', {})
