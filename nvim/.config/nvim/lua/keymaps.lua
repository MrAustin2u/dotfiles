local Utils = require("utils")
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

-- LSP Restart
vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<CR>", { desc = "LSP restart" })

-- lazygit
nmap({
  "<leader>gg",
  function()
    Utils.float_term({ "lazygit" }, { cwd = Utils.get_root(), esc_esc = false })
  end,
  Utils.merge_maps(default_opts, { desc = "Lazygit (root dir)" }),
})
nmap({
  "<leader>gG",
  function()
    Utils.float_term({ "lazygit" }, { esc_esc = false })
  end,
  Utils.merge_maps(default_opts, { desc = "Lazygit (cwd)" }),
})

M.attempt = function(attempt)
  nmap({ "<leader>an", attempt.new_select, default_opts })
  nmap({ "<leader>ar", attempt.run, default_opts })
  nmap({ "<leader>ad", attempt.delete_buf, default_opts })
  nmap({ "<leader>ac", attempt.rename_buf, default_opts })
  nmap({ "<leader>al", "<cmd>Telescope attempt", default_opts })
end

M.cokeline = function()
  nmap({ "<S-Tab>", "<Plug>(cokeline-focus-prev)", { silent = true, desc = "Prev Tab" } })
  nmap({ "<Tab>", "<Plug>(cokeline-focus-next)", { silent = true, desc = "Next Tab" } })
end

M.dadbod_mappings = function()
  nmap({ "<leader>do", ":DBUI<CR><CR>", { silent = true, desc = "Database UI Open" } })
  nmap({ "<leader>dc", ":DBUIClose<CR>", { silent = true, desc = "Database UI Close" } })
end

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
  -- K = hover doc
  buf_nmap("K", "<cmd>lua vim.lsp.buf.hover()<CR>")
  -- bf = buffer format
  buf_nmap("<leader>bf", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>")
end

M.lsp_diagnostic_mappings = function()
  nmap({ "<leader>do", "<cmd>lua vim.diagnostic.open_float()<CR>", default_opts })
  nmap({ "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", default_opts })
  nmap({ "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", default_opts })
  nmap({ "<leader>qd", "<cmd>lua vim.diagnostic.setloclist()<CR>", default_opts })
end

M.lsp_saga_mappings = function()
  -- Lsp finder find the symbol definition implmement reference
  nmap({ "<leader>ca", "<cmd><c-u>Lspsaga range_code_action<cr>", silent })
  nmap({ "<leader>ca", "<cmd>Lspsaga code_action<cr>", silent })
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
  -- nmap({ "K", "<cmd>Lspsaga hover_doc<CR>", silent })
end

M.nvim_tree_mappings = function()
  nmap({
    "<leader>nf",
    "<cmd>lua require('nvim-tree.api').tree.toggle({find_file = true})<CR>",
    {
      desc = "NvimTree - Toggle Find File",
    },
  })
end

M.telescope_mappings = function()
  nmap({ "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", default_opts })
  nmap({ "<leader>f:", "<cmd>Telescope commands<cr>", default_opts })
  nmap({ "<leader>f;", "<cmd>Telescope command_history<cr>", default_opts })
  nmap({ "<leader>f?", "<cmd>Telescope search_history<cr>", default_opts })
  nmap({ "<leader>ff", "<cmd>Telescope find_files<cr>", { silent = true, noremap = true, desc = "Find Files" } })
  nmap({ "<leader>fg", "<cmd>Telescope git_files<cr>", { silent = true, noremap = true, desc = "Find Git Files" } })
  nmap({ "<leader>sg", "<cmd>Telescope live_grep<cr>", default_opts })
  nmap({ "<leader>sw", "<cmd>Telescope grep_string<cr>", default_opts })
  nmap({ "<leader>fh", "<cmd>Telescope help_tags<cr>", default_opts })
  nmap({ "<leader>fk", "<cmd>Telescope keymaps<cr>", default_opts })
  nmap({ "<leader>fo", "<cmd>Telescope oldfiles<cr>", default_opts })
  nmap({ "<leader>fO", "<cmd>Telescope vim_options<cr>", default_opts })
  nmap({ "<leader>fr", "<cmd>Telescope resume<cr>", default_opts })

  --  Extensions
  nmap({ "<leader>fb", "<cmd>Telescope file_browser<cr>", default_opts })

  nmap({ "<leader>bb", "<cmd>Telescope buffers<cr>", default_opts })

  -- better spell suggestions
  nmap({ "z=", "<cmd>Telescope spell_suggest<cr>", default_opts })

  -- LSP
  -- find references
  nmap({ "fr", "<cmd>Telescope lsp_references<cr>", default_opts })
  -- ds = document symbols
  nmap({ "<leader>ds", "<cmd>Telescope lsp_document_symbols<cr>", default_opts })

  nmap({ "<leader>cc", "<cmd>Telescope conventional_commits<cr>", default_opts })

  -- GitHub
  nmap({ "<leader>ga", "<cmd>Telescope gh run<cr>", default_opts })
  nmap({ "<leader>gi", "<cmd>Telescope gh issues<cr>", default_opts })
  nmap({ "<leader>gp", "<cmd>Telescope gh pull_request<cr>", default_opts })
end

M.attempt_mappings = function(attempt)
  -- new attempt, selecting extension
  nmap({ "<leader>an", attempt.new_select, Utils.merge_maps(default_opts, { desc = "New Attempt" }) })
  -- run current attempt buffer
  nmap({ "<leader>ar", attempt.run, Utils.merge_maps(default_opts, { desc = "Run Attempt" }) })
  -- delete attempt from current buffer
  nmap({ "<leader>ad", attempt.delete_buf, Utils.merge_maps(default_opts, { desc = "Delete Attempt" }) })
  -- rename attempt from current buffer
  nmap({ "<leader>ac", attempt.rename_buf, Utils.merge_maps(default_opts, { desc = "Rename Attempt" }) })
  -- open one of the existing scratch buffers
  nmap({ "<leader>al", attempt.open_select, Utils.merge_maps(default_opts, { desc = "Select Attempt" }) })
end

M.gitsigns_mappings = function(gitsigns, bufnr)
  local opts = { expr = true, buffer = bufnr }

  local next_hunk = function()
    if vim.wo.diff then
      return "]c"
    end
    vim.schedule(function()
      gitsigns.next_hunk()
    end)
    return "<Ignore>"
  end

  local prev_hunk = function()
    if vim.wo.diff then
      return "[c"
    end
    vim.schedule(function()
      gitsigns.prev_hunk()
    end)
    return "<Ignore>"
  end

  -- Navigation
  nmap({ "]h", next_hunk, opts })
  nmap({ "[h", prev_hunk, opts })

  -- Hunk operations
  -- Reset Hunk
  nmap({ "<leader>gr", ":Gitsigns reset_hunk<CR>" })
  vmap({ "<leader>gr", ":Gitsigns reset_hunk<CR>" })
  -- Stage Hunk
  nmap({ "<leader>gs", ":Gitsigns stage_hunk<CR>" })
  vmap({ "<leader>gs", ":Gitsigns stage_hunk<CR>" })
  -- Undo Stage Hunk
  nmap({ "<leader>gu", ":Gitsigns undo_stage_hunk<CR>" })
  vmap({ "<leader>gu", ":Gitsigns undo_stage_hunk<CR>" })

  -- Text object for git hunks (e.g. vih will select the hunk)
  map({ { "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>" })
end

M.noice_mappings = function(noice)
  nmap({
    "<S-Enter>",
    function()
      noice.redirect(vim.fn.getcmdline())
    end,
    mode = "c",
    desc = "Redirect Cmdline",
  })
  nmap({
    "<leader>snl",
    function()
      noice.cmd("last")
    end,
    desc = "Noice Last Message",
  })
  nmap({
    "<leader>snh",
    function()
      noice.cmd("history")
    end,
    desc = "Noice History",
  })
  nmap({
    "<leader>sna",
    function()
      noice.cmd("all")
    end,
    desc = "Noice All",
  })
  nmap({
    "<c-f>",
    function()
      if not noice.lsp.scroll(4) then
        return "<c-f>"
      end
    end,
    silent = true,
    expr = true,
    desc = "Scroll forward",
    mode = {
      "i",
      "n",
      "s",
    },
  })
  nmap({
    "<c-b>",
    function()
      if not require("noice.lsp").scroll(-4) then
        return "<c-b>"
      end
    end,
    silent = true,
    expr = true,
    desc = "Scroll backward",
    mode = {
      "i",
      "n",
      "s",
    },
  })
end

M.persistence_mappings = function(p)
  nmap({
    "<leader>qs",
    function()
      p.load()
    end,
    { silent = true, desc = "Restore Session" },
  })
  nmap({
    "<leader>ql",
    function()
      p.load({ last = true })
    end,
    { silent = true, desc = "Restore Last Session" },
  })
  nmap({
    "<leader>qd",
    function()
      p.stop()
    end,
    { silent = true, desc = "Don't Save Current Session" },
  })
end

M.rest_mappings = function()
  nmap({ "<leader>rf", "<Plug>RestNvim<CR>", default_opts })
  nmap({ "<leader>rl", "<Plug>RestNvimLast<CR>", default_opts })
  nmap({ "<leader>rp", "<Plug>RestNvimPreview<CR>", default_opts })
end

M.spectre_mappings = function(spectre)
  nmap({
    "<leader>sr",
    function()
      spectre.open()
    end,
    { silent = true, desc = "Replace in files (Spectre)" },
  })
end

M.silicon_mappings = function()
  nmap({ "<leader>SS", "<cmd>Silicon!<cr>", mode = "v", { silent = true, desc = "Screenshot a code snippet" } })
  nmap({
    "<leader>sc",
    ":Silicon<cr>",
    mode = "v",
    { silent = true, desc = "Screenshot a code snippet into the clipboard" },
  })
end

M.trouble_mappings = function()
  nmap({ "<leader>xx", "<cmd>TroubleToggle<cr>", { silent = true, desc = "Trouble Toggle" } })
  nmap({ "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { silent = true, desc = "Trouble Workspace" } })
  nmap({ "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", { silent = true, desc = "Trouble Document" } })
  nmap({ "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", { silent = true, desc = "Trouble Quickfix" } })
  nmap({ "<leader>xl", "<cmd>TroubleToggle loclist<cr>", { silent = true, desc = "Trouble Loclist" } })
  nmap({ "<leader>xr", "<cmd>TroubleToggle lsp_references<cr>", { silent = true, desc = "Trouble LSP" } })
end

M.vim_notify_mappings = function(notify)
  nmap({
    "<leader>un",
    function()
      notify.dismiss({ silent = true, pending = true })
    end,
    {
      silent = true,
      desc = "Delete all Notifications",
    },
  })
end

M.vim_test_mappings = function()
  nmap({ "<leader>tn", ":TestNearest<CR>" })
  nmap({ "<leader>tf", ":TestFile<CR>" })
  nmap({ "<leader>ts", ":TestSuite<CR>" })
  nmap({ "<leader>tl", ":TestLast<CR>" })
end

return M
