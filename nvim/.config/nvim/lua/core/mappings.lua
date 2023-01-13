---@diagnostic disable: unused-local
local utils = require 'core.utils'

--[[
╭────────────────────────────────────────────────────────────────────────────╮
│  Str  │  Help page   │  Affected modes                           │  VimL   │
│────────────────────────────────────────────────────────────────────────────│
│  ''   │  mapmode-nvo │  Normal, Visual, Select, Operator-pending │  :map   │
│  'n'  │  mapmode-n   │  Normal                                   │  :nmap  │
│  'v'  │  mapmode-v   │  Visual and Select                        │  :vmap  │
│  's'  │  mapmode-s   │  Select                                   │  :smap  │
│  'x'  │  mapmode-x   │  Visual                                   │  :xmap  │
│  'o'  │  mapmode-o   │  Operator-pending                         │  :omap  │
│  '!'  │  mapmode-ic  │  Insert and Command-line                  │  :map!  │
│  'i'  │  mapmode-i   │  Insert                                   │  :imap  │
│  'l'  │  mapmode-l   │  Insert, Command-line, Lang-Arg           │  :lmap  │
│  'c'  │  mapmode-c   │  Command-line                             │  :cmap  │
│  't'  │  mapmode-t   │  Terminal                                 │  :tmap  │
╰────────────────────────────────────────────────────────────────────────────╯
--]]

local map = utils.map
local cmap = utils.cmap
local imap = utils.imap
local nmap = utils.nmap
local tmap = utils.tmap
local vmap = utils.vmap
local xmap = utils.xmap

local buf_nmap = utils.buf_nmap

local silent = { silent = true }
local default_opts = { noremap = true, silent = true }

-- ==================================
-- # Convenience
-- ===================================

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
map { { 'n', 'v' }, '<space>', '<nop>', silent }
nmap { '<leader>q', '<cmd>q!<CR>', silent }
nmap { ';', ':' }
-- quit this ish...
nmap { '<leader>q', '<cmd>q!<CR>' }

-- sort selected lines
vmap { 'gs', ':sort<CR>' }

-- ==================================
-- # Splits
-- ===================================

-- Navigation
nmap { '<C-h>', '<C-W>h' }
nmap { '<C-j>', '<C-W>j' }
nmap { '<C-k>', '<C-W>k' }
nmap { '<C-l>', '<C-W>l' }

-- Resize
nmap { '<M-Left>', ':vertical resize +3<CR>', silent }
nmap { '<M-Right>', ':vertical resize -3<CR>', silent }
nmap { '<M-Up>', ':resize -3<CR>', silent }
nmap { '<M-Down>', ':resize +3<CR>', silent }

-- ==================================
-- # Save and source files
-- ===================================

-- save and execute vim/lua file
nmap {
  '<leader>x',
  function()
    if vim.bo.filetype == 'vim' then
      vim.cmd 'silent! write'
      vim.cmd 'source %'
      vim.api.nvim_echo({ { 'Saving and sourcing vim file...' } }, true, {})
    elseif vim.bo.filetype == 'lua' then
      vim.cmd 'silent! write'
      vim.cmd 'luafile %'
      vim.api.nvim_echo({ { 'Saving and sourcing lua file...' } }, true, {})
    end
  end,
}

nmap { '<leader>w', '<cmd>w<CR>' }

-- ================================
-- # File Jumps
-- ================================

-- ================================
-- # Learn how to spell stupid!
-- ================================

nmap { '<leader>z', '<cmd>setlocal spell!<CR>' }
nmap { '<leader>=', 'z=' }
nmap { '<leader>]', ']s' }

-- ================================
-- # A Tab bit much
-- ================================

-- Go to tab by number
nmap { '<leader>1', '1gt' }
nmap { '<leader>2', '2gt' }
nmap { '<leader>3', '3gt' }
nmap { '<leader>4', '4gt' }
nmap { '<leader>5', '5gt' }
nmap { '<leader>6', '6gt' }
nmap { '<leader>7', '7gt' }
nmap { '<leader>8', '8gt' }
nmap { '<leader>9', '9gt' }

nmap { '<leader>0', '<cmd>tablast<CR>' }

nmap { '<C-Left>', '<cmd>tabprevious<CR>' }
nmap { '<C-Right>', '<cmd>tabnext<CR>' }

-- ================================
-- # Plug{Packer}
-- ================================

nmap { '<leader>pi', '<cmd>PackerInstall<CR>' }
nmap { '<leader>ps', '<cmd>PackerSync<CR>' }
nmap { '<leader>pc', '<cmd>PackerCompile<CR>' }
nmap { '<leader>pu', '<cmd>PackerUpdate<CR>' }

-- ================================
-- # Misc
-- ================================
--NEVER ALLOW THIS
nmap { 'Q', '<nop>' }

-- Shut up already
nmap { '<leader>,', '<cmd>noh<CR>' }

nmap { '<leader>v', 'ggVG' }

-- ================================
-- # Copy, Paste, Movements, Etc..
-- ================================

-- copy to end of line
nmap { 'Y', 'y$' }

-- copy to system clipboard
nmap { 'gy', '"+y' }
vmap { 'gy', '"+y' }

-- copy to to system clipboard (till end of line)
nmap { 'gY', '"+y$' }

-- copy entire file
nmap { '<C-g>y', 'ggyG' }

-- copy entire file to system clipboard
nmap { '<C-g>Y', 'gg"+yG' }

--[[ xmap { "<leader>p", "'_dp" } ]]

-- Move yanked text vertically
vmap { 'J', ":m '>+1<CR>gv=gv" }
vmap { 'K', ":m '<-2<CR>gv=gv" }

-- Append line below and keep curosr position
nmap { 'J', 'mzJ`z' }

-- Autocenter search terms
nmap { 'n', 'nzzzv' }
nmap { 'N', 'Nzzzv' }

-- Autocenter half file jumps
nmap { '<C-d>', '<C-d>zz' }
nmap { '<C-u>', '<C-u>zz' }

--[[ PLUGIN MAPPINGS ]]
local M = {}

M.attempt_mappings = function(attempt)
  -- new attempt, selecting extension
  nmap { '<leader>sn', attempt.new_select, default_opts }
  -- run current attempt buffer
  nmap { '<leader>sr', attempt.run, default_opts }
  -- delete attempt from current buffer
  nmap { '<leader>sd', attempt.delete_buf, default_opts }
  -- rename attempt from current buffer
  nmap { '<leader>sc', attempt.rename_buf, default_opts }
  -- open one of the existing scratch buffers
  nmap { '<leader>sl', attempt.open_select, default_opts }
end

M.bufferline_mappings = function()
  nmap { '<leader>bd', '<cmd>BufDel<CR>', default_opts }
  nmap { '<leader>bp', '<Cmd>BufferLinePick<CR>', default_opts }
  nmap { '<leader>bs', '<Cmd>BufferLineSortByDirectory<CR>', default_opts }
  nmap { '<S-l>', '<cmd>BufferLineCycleNext<CR>', default_opts }
  nmap { '<S-h>', '<cmd>BufferLineCyclePrev<CR>', default_opts }
end

M.easy_align_mappings = function()
  nmap { '<leader>ea', ':EasyAlign ' }
  xmap { '<leader>ea', ':EasyAlign ' }
end

M.fugitive_mappings = function()
  -- Git Stage file
  nmap { '<leader>gS', ':Gwrite<CR>', default_opts }

  -- Git Blame
  nmap { '<leader>gb', ':Git blame<CR>', default_opts }
  vmap { '<leader>gb', ':Git blame<CR>', default_opts }

  --  Grep project for word under the cursor with Rg
  nmap { '<Leader>gR', ':Gread<CR>', default_opts }

  -- open github page for file
  nmap { '<leader>gO', ':GBrowse<CR>', default_opts }

  -- open github page for line under cursor
  nmap { '<leader>go', ':.GBrowse<CR>', default_opts }

  -- open github page for selection
  vmap { '<leader>go', ':GBrowse<CR>', default_opts }

  -- copy github link for file
  nmap { '<leader>gY', ':GBrowse! | lua vim.notify("Copied file URL to clipboard")<CR>', default_opts }

  -- copy github link for line under cursor
  nmap { '<leader>gy', ':.GBrowse! | lua vim.notify("Copied line URL to clipboard")<CR>', default_opts }

  -- copy github link for selection
  vmap { '<leader>gy', ':GBrowse! | lua vim.notify("Copied selection URL to clipboard")<CR>', default_opts }
end

M.gitsigns_mappings = function(gitsigns, bufnr)
  local opts = { expr = true, buffer = bufnr }

  local next_hunk = function()
    if vim.wo.diff then
      return ']c'
    end
    vim.schedule(function()
      gitsigns.next_hunk()
    end)
    return '<Ignore>'
  end

  local prev_hunk = function()
    if vim.wo.diff then
      return '[c'
    end
    vim.schedule(function()
      gitsigns.prev_hunk()
    end)
    return '<Ignore>'
  end

  -- Navigation
  nmap { ']h', next_hunk, opts }
  nmap { '[h', prev_hunk, opts }

  -- Hunk operations
  -- Reset Hunk
  nmap { '<leader>gr', ':Gitsigns reset_hunk<CR>' }
  vmap { '<leader>gr', ':Gitsigns reset_hunk<CR>' }

  -- Stage Hunk
  nmap { '<leader>gs', ':Gitsigns stage_hunk<CR>' }
  vmap { '<leader>gs', ':Gitsigns stage_hunk<CR>' }

  -- Undo Stage Hunk
  nmap { '<leader>gu', ':Gitsigns undo_stage_hunk<CR>' }
  vmap { '<leader>gu', ':Gitsigns undo_stage_hunk<CR>' }

  -- View Full Blame
  nmap { '<leader>gb', "<cmd>lua require'gitsigns'.blame_line{full=true}<CR>", default_opts }

  -- Text object for git hunks (e.g. vih will select the hunk)
  map { { 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>' }
end

M.harpoon_mappings = function()
  local mark = require 'harpoon.mark'
  local ui = require 'harpoon.ui'

  nmap { '<leader>m', mark.add_file }
  nmap { '<C-e>', ui.toggle_quick_menu }

  -- file navigatyion
  nmap {
    '<leader>l',
    function()
      ui.nav_next()
    end,
  }

  nmap {
    '<leader>h',
    function()
      ui.nav_prev()
    end,
  }

  nmap { '<C-e>', ui.toggle_quick_menu }

  nmap {
    '<C-h>',
    function()
      ui.nav_file(1)
    end,
  }
  nmap {
    '<C-t>',
    function()
      ui.nav_file(2)
    end,
  }
  nmap {
    '<C-n>',
    function()
      ui.nav_file(3)
    end,
  }
  nmap {
    '<C-s>',
    function()
      ui.nav_file(4)
    end,
  }
end

M.lsp_mappings = function(bufnr)
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  -- gD = go Declaration
  buf_nmap(bufnr, 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', default_opts)
  -- gD = go definition
  buf_nmap(bufnr, 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', default_opts)
  -- gi = go implementation
  buf_nmap(bufnr, 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', default_opts)
  -- fs = function signature
  buf_nmap(bufnr, '<leader>gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', default_opts)
  -- D = <type> Definition
  buf_nmap(bufnr, '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', default_opts)
  -- f = format
  buf_nmap(bufnr, 'f', '<cmd>lua vim.lsp.buf.format()<CR>', default_opts)
end

M.lsp_diagnostic_mappings = function()
  nmap { '<leader>do', '<cmd>lua vim.diagnostic.open_float()<CR>', default_opts }
  nmap { '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', default_opts }
  nmap { ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', default_opts }
  nmap { '<leader>qd', '<cmd>lua vim.diagnostic.setloclist()<CR>', default_opts }
end

M.lsp_saga_mappings = function()
  -- Lsp finder find the symbol definition implmement reference
  nmap { '<leader>lf', '<cmd>Lspsaga lsp_finder<CR>', silent }

  -- Code action
  nmap { '<leader>ca', '<cmd>Lspsaga code_action<CR>', silent }
  vmap { '<leader>ca', '<cmd><C-U>Lspsaga range_code_action<CR>', silent }

  -- Rename
  nmap { '<leader>rn', '<cmd>Lspsaga rename<CR>', silent }

  -- Definition preview
  nmap { 'gp', '<cmd>Lspsaga peek_definition<CR>', silent }

  -- Show line diagnostics
  nmap { '<leader>ld', '<cmd>Lspsaga show_line_diagnostics<CR>', silent }

  -- Show cursor diagnostic
  nmap { '<leader>cd', '<cmd>Lspsaga show_cursor_diagnostics<CR>', silent }

  -- Diagnsotic jump
  nmap { '[e', '<cmd>Lspsaga diagnostic_jump_prev<CR>', silent }
  nmap { ']e', '<cmd>Lspsaga diagnostic_jump_next<CR>', silent }

  -- Only jump to error
  nmap {
    '[E',
    function()
      require('lspsaga.diagnostic').goto_prev { severity = vim.diagnostic.severity.ERROR }
    end,
    silent,
  }

  nmap {
    ']E',
    function()
      require('lspsaga.diagnostic').goto_next { severity = vim.diagnostic.severity.ERROR }
    end,
    silent,
  }

  -- Outline
  nmap { '<leader>ol', '<cmd>LSoutlineToggle<CR>', silent }

  -- Hover Doc
  nmap { 'K', '<cmd>Lspsaga hover_doc<CR>', silent }
end

M.nvim_tree_mappings = function()
  nmap { '<leader>nt', ':NvimTreeToggle<CR>', default_opts }
  nmap { '<leader>nf', ':NvimTreeFindFile<CR>', default_opts }
  nmap { '<leader>nc', ':NvimTreeClose<CR>', default_opts }
  nmap { '<leader>nr', ':NvimTreeRefresh<CR>', default_opts }
end

M.packer_mappings = function()
  nmap { '<leader>pl', '<cmd>PackerCompile<CR>' }
  nmap { '<leader>ps', '<cmd>PackerSync<CR>' }
  nmap { '<leader>pc', '<cmd>PackerClean<CR>' }
end

M.telescope_mappings = function()
  -- muscle memory
  nmap { '<C-p>', '<cmd>Telescope find_files<cr>', default_opts }
  nmap { '<C-b>', '<cmd>Telescope buffers<cr>', default_opts }

  -- Compatible with hydra setup
  nmap { '<leader>f/', '<cmd>Telescope current_buffer_fuzzy_find<cr>', default_opts }
  nmap { '<leader>f:', '<cmd>Telescope commands<cr>', default_opts }
  nmap { '<leader>f;', '<cmd>Telescope command_history<cr>', default_opts }
  nmap { '<leader>f?', '<cmd>Telescope search_history<cr>', default_opts }
  nmap { '<leader>ff', '<cmd>Telescope find_files<cr>', default_opts }
  nmap { '<leader>fg', '<cmd>Telescope live_grep<cr>', default_opts }
  nmap { '<leader>fs', '<cmd>Telescope grep_string<cr>', default_opts }
  nmap { '<leader>fh', '<cmd>Telescope help_tags<cr>', default_opts }
  nmap { '<leader>fk', '<cmd>Telescope keymaps<cr>', default_opts }
  nmap { '<leader>fo', '<cmd>Telescope oldfiles<cr>', default_opts }
  nmap { '<leader>fO', '<cmd>Telescope vim_options<cr>', default_opts }
  nmap { '<leader>fr', '<cmd>Telescope resume<cr>', default_opts }

  --  Extensions
  nmap { '<leader>fb', '<cmd>Telescope file_browser<cr>', default_opts }
  nmap { '<leader>fp', '<cmd>Telescope packer<cr>', default_opts }

  nmap { '<leader>lg', '<cmd>Telescope live_grep<cr>', default_opts }
  nmap { '<leader>bb', '<cmd>Telescope buffers<cr>', default_opts }

  -- better spell suggestions
  nmap { 'z=', '<cmd>Telescope spell_suggest<cr>', default_opts }

  -- Git
  -- bc = buffer commits (like gitv!)
  nmap { '<leader>bc', '<cmd>Telescope git_bcommits<cr>', default_opts }

  -- LSP
  -- get references
  nmap { '<leader>gr', '<cmd>Telescope lsp_references<cr>', default_opts }
  -- ds = document symbols
  nmap { '<leader>ds', '<cmd>Telescope lsp_document_symbols<cr>', default_opts }

  nmap { '<leader>cc', '<cmd>Telescope conventional_commits<cr>', default_opts }

  -- GitHub
  nmap { '<leader>ga', '<cmd>Telescope gh run<cr>', default_opts }
  nmap { '<leader>gg', '<cmd>Telescope gh gist<cr>', default_opts }
  nmap { '<leader>gi', '<cmd>Telescope gh issues<cr>', default_opts }
  nmap { '<leader>gp', '<cmd>Telescope gh pull_request<cr>', default_opts }
end

M.trouble_mappings = function()
  nmap { '<leader>tt', '<cmd>TroubleToggle<cr>', default_opts }
  nmap { '<leader>tw', '<cmd>Trouble workspace_diagnostics<cr>', default_opts }
  nmap { '<leader>td', '<cmd>Trouble document_diagnostics<cr>', default_opts }
  nmap { '<leader>tl', '<cmd>Trouble loclist<cr>', default_opts }
  nmap { '<leader>tq', '<cmd>Trouble quickfix<cr>', default_opts }
  nmap { 'tR', '<cmd>Trouble lsp_references<cr>', default_opts }
end

M.undotree_mappings = function()
  nmap { '<leader>ut', '<cmd>UndotreeToggle<CR>' }
end

return M
