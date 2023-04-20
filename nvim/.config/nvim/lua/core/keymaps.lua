local Utils = require("core.utils")
local M = {}

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
local map = function(tbl)
  vim.keymap.set(tbl[1], tbl[2], tbl[3], tbl[4])
end

local imap = function(tbl)
  vim.keymap.set("i", tbl[1], tbl[2], tbl[3])
end

local nmap = function(tbl)
  vim.keymap.set("n", tbl[1], tbl[2], tbl[3])
end

local vmap = function(tbl)
  vim.keymap.set("v", tbl[1], tbl[2], tbl[3])
end

local tmap = function(tbl)
  vim.keymap.set("t", tbl[1], tbl[2], tbl[3])
end

local cmap = function(tbl)
  vim.keymap.set("c", tbl[1], tbl[2], tbl[3])
end

local silent = { silent = true }
local default_opts = { noremap = true, silent = true }

-- ================================
-- # Misc
-- ================================
-- quit all
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
vim.keymap.set("n", "<space>wq", ":wq <CR>", { silent = true, desc = "Save and Quit" })

-- command
vim.keymap.set("n", ";", ":")

-- Sort
vim.keymap.set("v", "ts", ":sort<CR>", { desc = "Text sort" })

-- save file
vim.keymap.set({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- save and source config files
vim.keymap.set({ "i", "v", "n", "s" }, "<C-x>", function()
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
vim.keymap.set("n", "<leader>l", "<cmd>:Lazy<cr>", { desc = "Lazy" })

-- new file
vim.keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- toggle options
vim.keymap.set("n", "<leader>us", function()
  Utils.toggle("spell")
end, { desc = "Toggle Spelling" })

vim.keymap.set("n", "<leader>uw", function()
  Utils.toggle("wrap")
end, { desc = "Toggle Word Wrap" })

vim.keymap.set("n", "<leader>ul", function()
  Utils.toggle("relativenumber", true)
  Utils.toggle("number")
end, { desc = "Toggle Line Numbers" })

vim.keymap.set("n", "<leader>ud", Utils.toggle_diagnostics, { desc = "Toggle Diagnostics" })
local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3

vim.keymap.set("n", "<leader>uc", function()
  Utils.toggle("conceallevel", false, { 0, conceallevel })
end, { desc = "Toggle Conceal" })

-- ================================
-- # Copy, Paste, Movements, Etc..
-- ================================
-- yanks
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- copy to end of line
vim.keymap.set("n", "Y", "y$", { desc = "Copy to end of line" })
-- copy entire file
vim.keymap.set("n", "<C-g>y", 'gg"+yG', { desc = "Copy entire file" })
-- copy entire file to system clipboard
vim.keymap.set("n", "<C-g>y", 'gg"+YG', { desc = "Copy entire file" })

-- better up/down
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- move lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

-- Move Lines
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi")
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-p>", function()
  vim.cmd("let @+ = expand('%')")
end, { desc = "Copy relative path" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
vim.keymap.set(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)

vim.keymap.set({ "n", "x" }, "gw", "*N", { desc = "Search word under cursor" })
-- buffer
vim.keymap.set(
  "n",
  "<space>bd",
  ":Bdelete <CR> <Plug>(cokeline-focus-prev)<CR>",
  { silent = true, desc = "Buffer Delete" }
)
vim.keymap.set("n", "<space>ba", ":%bdelete|edit#|bdelete# <CR>", { silent = true, desc = "Buffer Delete All" })

-- windows
vim.keymap.set("n", "<leader>ww", "<C-W>p", { desc = "Other window" })
vim.keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })
vim.keymap.set("n", "<leader>w-", "<C-W>s", { desc = "Split window below" })
vim.keymap.set("n", "<leader>w|", "<C-W>v", { desc = "Split window right" })
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split window right" })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- highlights under cursor
if vim.fn.has("nvim-0.9.0") == 1 then
  vim.keymap.set("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
end

-- browse
vim.keymap.set("n", "<leader>i", "<cmd>Browse<cr>", { desc = "Browse github and internet" })

-- Elixir
vim.keymap.set("n", "<leader>re", "<cmd>ElixirRestart<CR>", { desc = "Restart Elixir LSP" })

M.lsp_mappings = function(bufnr)
  local buf_nmap = function(mapping, cmd)
    vim.api.nvim_buf_set_keymap(bufnr, "n", mapping, cmd, default_opts)
  end

  local buf_vmap = function(mapping, cmd)
    vim.api.nvim_buf_set_keymap(bufnr, "v", mapping, cmd, default_opts)
  end

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  -- gD = go Declaration
  buf_nmap("gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
  -- gD = go definition
  buf_nmap("gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
  -- gi = go implementation
  buf_nmap("gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
  -- fs = function signature
  buf_nmap("<leader>fs", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
  -- wa = workspace add
  buf_nmap("<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>")
  -- wr = workspace remove
  buf_nmap("<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>")
  -- wl = workspace list
  buf_nmap("<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>")
  -- D = <type> Definition
  buf_nmap("<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
  -- ca = code action
  buf_nmap("<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
  -- ca = code action
  buf_vmap("<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
  -- gr = get references
  buf_nmap("gr", "<cmd>lua vim.lsp.buf.references()<CR>")
end

M.lsp_diagnostic_mappings = function()
  nmap({ "<leader>do", "<cmd>lua vim.diagnostic.open_float()<CR>", default_opts })
  nmap({ "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", default_opts })
  nmap({ "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", default_opts })
  nmap({ "<leader>qd", "<cmd>lua vim.diagnostic.setloclist()<CR>", default_opts })
end

M.lsp_saga_mappings = function()
  -- Lsp finder find the symbol definition implmement reference
  nmap({ "<leader>ca", ":<c-u>Lspsaga range_code_action<cr>", silent })
  nmap({ "<leader>ca", ":Lspsaga code_action<cr>", silent })
  nmap({ "<leader>lf", "<cmd>Lspsaga lsp_finder<CR>", silent })

  -- Rename
  nmap({ "<leader>rn", "<cmd>Lspsaga rename<CR>", silent })
  -- Definition preview
  nmap({ "gp", "<cmd>Lspsaga peek_definition<CR>", silent })

  -- Show line diagnostics
  nmap({ "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", silent })

  -- Show cursor diagnostic
  nmap({ "<leader>cd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", silent })

  -- Diagnsotic jump
  nmap({ "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", silent })
  nmap({ "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", silent })

  -- Only jump to error
  nmap({
    "[E",
    function()
      require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end,
    silent,
  })

  nmap({
    "]E",
    function()
      require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR })
    end,
    silent,
  })

  -- Outline
  nmap({ "<leader>ol", "<cmd>LSoutlineToggle<CR>", silent })

  -- Hover Doc
  nmap({ "K", "<cmd>Lspsaga hover_doc<CR>", silent })
end

M.telescope_mappings = function()
  nmap({ "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", default_opts })
  nmap({ "<leader>f:", "<cmd>Telescope commands<cr>", default_opts })
  nmap({ "<leader>f;", "<cmd>Telescope command_history<cr>", default_opts })
  nmap({ "<leader>f?", "<cmd>Telescope search_history<cr>", default_opts })
  nmap({ "<leader>ff", "<cmd>Telescope find_files<cr>", { silent = true, noremap = true, desc = "Find Files" } })
  nmap({ "<leader>fg", "<cmd>Telescope git_files<cr>", { silent = true, noremap = true, desc = "Find Git Files" } })
  nmap({ "<leader>fh", "<cmd>Telescope help_tags<cr>", default_opts })
  nmap({ "<leader>fk", "<cmd>Telescope keymaps<cr>", default_opts })
  nmap({ "<leader>fo", "<cmd>Telescope oldfiles<cr>", default_opts })
  nmap({ "<leader>fO", "<cmd>Telescope vim_options<cr>", default_opts })
  nmap({ "<leader>fr", "<cmd>Telescope resume<cr>", default_opts })

  --  Extensions
  nmap({ "<leader>fb", "<cmd>Telescope file_browser<cr>", default_opts })

  nmap({ "<leader>lg", "<cmd>Telescope live_grep<cr>", default_opts })
  nmap({ "<leader>bb", "<cmd>Telescope buffers<cr>", default_opts })

  -- better spell suggestions
  nmap({ "z=", "<cmd>Telescope spell_suggest<cr>", default_opts })

  -- LSP
  -- ds = document symbols
  nmap({ "<leader>ds", "<cmd>Telescope lsp_document_symbols<cr>", default_opts })

  nmap({ "<leader>cc", "<cmd>Telescope conventional_commits<cr>", default_opts })

  -- GitHub
  nmap({ "<leader>ga", "<cmd>Telescope gh run<cr>", default_opts })
  nmap({ "<leader>gg", "<cmd>Telescope gh gist<cr>", default_opts })
  nmap({ "<leader>gi", "<cmd>Telescope gh issues<cr>", default_opts })
  nmap({ "<leader>gp", "<cmd>Telescope gh pull_request<cr>", default_opts })
end

return M
