local utils = require("aa.utils")
local nnoremap = aa.nnoremap
local vnoremap = aa.vnoremap

-- ==================================
-- # Convenience
-- ===================================

vim.api.nvim_set_keymap("n", ";", ":", { noremap = true, silent = false })
nnoremap("<leader>q", "<cmd>q!<CR>")

nnoremap("<C-h>", "<C-w>h")
nnoremap("<C-j>", "<C-w>j")
nnoremap("<C-k>", "<C-w>k")
nnoremap("<C-l>", "<C-w>l")

-- ==================================
-- # Save and source files
-- ===================================

-- save and execute vim/lua file
nnoremap("<Leader>x", utils.save_and_source)
nnoremap("<leader>s", "<cmd>w<CR>")

-- ===================================
-- # Nvim-Tree
-- ===================================

nnoremap("nf", "<cmd>:NvimTreeFindFile<CR>")
nnoremap("nc", "<cmd>:NvimTreeClose<CR>")
nnoremap("nr", "<cmd>:NvimTreeRefresh<CR>")

-- ===================================
-- # Telescope
-- ===================================

nnoremap(
  "<leader>vrc",
  "<cmd>lua require'telescope.builtin'.find_files({ prompt_title = '< VimRC >', cwd = '~/.config/nvim/', hidden = true,})<CR>"
)
nnoremap("<leader>ff", "<cmd>Telescope git_files<CR>")
nnoremap("<leader>fg", "<cmd>Telescope live_grep<CR>")
nnoremap("<leader>fs", "<cmd>Telescope grep_string<CR>")
nnoremap("<leader>fb", "<cmd>Telescope buffers<CR>")
nnoremap("<leader>fh", "<cmd>Telescope help_tags<CR>")
nnoremap("<leader>km", "<cmd>Telescope keymaps<CR>")
nnoremap("gr", "<cmd>lua require'telescope.builtin'.lsp_references{}<CR>")
nnoremap("gd", "<cmd>lua require'telescope.builtin'.lsp_definitions{}<CR>")
nnoremap("gt", "<cmd>lua require'telescope.builtin'.lsp_type_definitions{}<CR>")
nnoremap("<space>E", "<cmd>lua require'telescope.builtin'.diagnostics({ bufnr = 0 })<CR>")
nnoremap("<leader>os", "<cmd>lua require('session-lens').search_session()<CR>")

-- Shut up already
nnoremap("<Leader>,", ":noh<CR>")

nnoremap("<leader>v", "ggVG")

-- Yanking and pasting from system clipboard
vnoremap("Y", [["+y]])
nnoremap("<Leader>y", '"*y')
nnoremap("<Leader>Y", '"*Y')
vnoremap("<Leader>y", '"*y')
nnoremap("<Leader>p", '"*p')
nnoremap("<Leader>P", '"*P')

-- ================================
-- # File Jumps
-- ================================

-- Autocenter file jumps
vim.cmd([[
nnoremap("n", "nzzzv")
nnoremap("N", "Nzzzv")
]])
-- ================================
-- # Learn how to spell stupid!
-- ================================

nnoremap("<leader>z", "<cmd>setlocal spell!<CR>")
nnoremap("<leader>=", "z=")
nnoremap("<leader>]", "]s")

-- ================================
-- # A Tab bit much
-- ================================

-- Go to tab by number
nnoremap("<leader>1", "1gt")
nnoremap("<leader>2", "2gt")
nnoremap("<leader>3", "3gt")
nnoremap("<leader>4", "4gt")
nnoremap("<leader>5", "5gt")
nnoremap("<leader>6", "6gt")
nnoremap("<leader>7", "7gt")
nnoremap("<leader>8", "8gt")
nnoremap("<leader>9", "9gt")
nnoremap("<leader>0", "<cmd>tablast<CR>")

nnoremap("<C-Left>", "<cmd>tabprevious<CR>")
nnoremap("<C-Right>", "<cmd>tabnext<CR>")

-- ================================
-- # Sort
-- ================================
nnoremap("<leader>S", "<cmd>!sort<CR>")

-- ================================
-- # Plug(Packer)
-- ================================

nnoremap("<leader>pi", "<cmd>PackerInstall<CR>")
nnoremap("<leader>pu", "<cmd>PackerUpdate<CR>")
nnoremap("<leader>pc", "<cmd>PackerClean<CR>")

-- ================================
-- # Git
-- ================================

nnoremap("<leader>gb", "<cmd>lua require'gitsigns'.blame_line{full=true}<CR>")
nnoremap("<leader>dv", "<cmd>DiffviewOpen<CR>")
nnoremap("<leader>dc", "<cmd>DiffviewClose<CR>")
nnoremap("<leader>gh", "<cmd>diffget //2<CR>")
nnoremap("<leader>gl", "<cmd>diffget //3<CR>")

-- ================================
-- # Dash
-- ================================

nnoremap("<leader>da", "<cmd>lua require('dash.providers.telescope').dash({ bang = false, initial_text = '' })<CR>")

-- ================================
-- # LSP
-- ================================
nnoremap("<leader>xx", "<cmd>Trouble<CR>")
nnoremap("<leader>xc", "<cmd>TroubleClose<CR>")
nnoremap("<leader>xw", "<cmd>Trouble workspace_diagnostics<CR>")
nnoremap("<leader>xd", "<cmd>Trouble document_diagnostics<CR>")
nnoremap("<leader>xl", "<cmd>Trouble loclist<CR>")
nnoremap("<leader>xq", "<cmd>Trouble quickfix<CR>")
nnoremap("gR", "<cmd>Trouble lsp_references<CR>")

-- ================================
-- # Bufferline
-- ================================
nnoremap("<leader>bd", "<cmd>BufDel<CR>")
nnoremap("<leader>bp", "<Cmd>BufferLinePick<CR>")
nnoremap("<S-l>", "<cmd>BufferLineCycleNext<CR>")
nnoremap("<S-h>", "<cmd>BufferLineCyclePrev<CR>")

-- ================================
-- # Illuminate
-- ================================
nnoremap("<M-n>", "<cmd>lua require'illuminate'.next_reference{wrap=true}<CR>")
nnoremap("<M-p>", "<cmd>lua require'illuminate'.next_reference{reverse=true,wrap=true}<CR>")
