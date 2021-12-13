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

nnoremap("<leader>vrc", "<cmd>lua require'telescope.builtin'.find_files({ prompt_title = '< VimRC >', cwd = '~/.config/nvim/', hidden = true,})<CR>")
nnoremap("<leader>ff", "<cmd>Telescope git_files<CR>")
nnoremap("<leader>fg", "<cmd>Telescope live_grep<CR>")
nnoremap("<leader>fs", "<cmd>Telescope grep_string<CR>")
nnoremap("<leader>fb", "<cmd>Telescope buffers<CR>")
nnoremap("<leader>fh", "<cmd>Telescope help_tags<CR>")
nnoremap("<leader>km", "<cmd>Telescope keymaps<CR>")
nnoremap("gr", "<cmd>lua require'telescope.builtin'.lsp_references{}<CR>")
nnoremap("gd", "<cmd>lua require'telescope.builtin'.lsp_definitions{}<CR>")
nnoremap("ca", "<cmd>lua require'telescope.builtin'.lsp_code_actions(require('telescope.themes').get_cursor({}))<CR>")
nnoremap("<space>E", "<cmd>lua require'telescope.builtin'.lsp_document_diagnostics{}<CR>")

-- ===================================
-- # FZF
-- ===================================
-- nnoremap("<leader>ff", "<cmd>lua require('fzf-lua').git_files()<cr>")
-- nnoremap("<leader>fb", "<cmd>lua require('fzf-lua').buffers()<cr>")
-- nnoremap("<leader>fo", "<cmd>lua require('fzf-lua').oldfiles()<cr>")
-- nnoremap("<leader>fk", "<cmd>lua require('fzf-lua').keymaps()<cr>")
-- nnoremap("<leader>fh", "<cmd>lua require('fzf-lua').help_tags()<cr>")
-- nnoremap("<leader>a", "<cmd>lua require('fzf-lua').live_grep()<cr>")
-- nnoremap("<leader>A", "<cmd>lua require('fzf-lua').grep_cword()<cr>")
-- nnoremap("<leader>gd", "<cmd>lua require('fzf-lua').lsp_definitions()<cr>")
-- nnoremap("<leader>gr", "<cmd>lua require('fzf-lua').lsp_references()<cr>")
-- -- TODO: figure out how to use shortened paths
-- nnoremap("<leader>vrc", [[<cmd>lua require("fzf-lua").files({ cwd = "~/.config/nvim/", prompt = "NVIM Config  " })<cr>]])
-- ===================================
-- # Searching, Pasting, Highlighting
-- ===================================

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
vim.cmd [[
nnoremap("n", "nzzzv")
nnoremap("N", "Nzzzv")
]]
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

nnoremap("gb", "<cmd>Gitsigns blame_line<CR>")
nnoremap("<leader>dv", "<cmd>DiffviewOpen<CR>")
nnoremap("<leader>dc", "<cmd>DiffviewClose<CR>")
nnoremap("<leader>ng", "<cmd>Neogit<CR>")
nnoremap("<leader>gh", "<cmd>diffget //2<CR>")
nnoremap("<leader>gl", "<cmd>diffget //3<CR>")

-- ================================
-- # Dash
-- ================================

nnoremap("<leader>da", "<cmd>Dash<CR>")

-- ================================
-- # LSP
-- ================================
nnoremap("<leader>xx", "<cmd>Trouble<CR>")
nnoremap("<leader>xc", "<cmd>TroubleClose<CR>")
nnoremap("<leader>xw", "<cmd>Trouble lsp_workspace_diagnostics<CR>")
nnoremap("<leader>xd", "<cmd>Trouble lsp_document_diagnostics<CR>")
nnoremap("<leader>xl", "<cmd>Trouble loclist<CR>")
nnoremap("<leader>xq", "<cmd>Trouble quickfix<CR>")
nnoremap("gR", "<cmd>Trouble lsp_references<CR>")

-- ================================
-- # Hop
-- ================================
nnoremap("f", "<cmd>HopWord<CR>")
nnoremap("F", "<cmd>HopPattern<CR>")
