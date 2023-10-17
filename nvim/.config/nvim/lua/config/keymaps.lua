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
--
local silent = { silent = true }
local default_opts = { noremap = true, silent = true }

local map = function(tbl)
  local opts = tbl[4] and Utils.merge_maps(default_opts, tbl[3]) or default_opts
  vim.keymap.set(tbl[1], tbl[2], tbl[3], opts)
end

local nmap = function(tbl)
  local opts = tbl[3] and Utils.merge_maps(default_opts, tbl[3]) or default_opts
  vim.keymap.set("n", tbl[1], tbl[2], opts)
end

local tmap = function(tbl)
  local opts = tbl[3] and Utils.merge_maps(default_opts, tbl[3]) or default_opts
  vim.keymap.set("t", tbl[1], tbl[2], opts)
end

local vmap = function(tbl)
  local opts = tbl[3] and Utils.merge_maps(default_opts, tbl[3]) or default_opts
  vim.keymap.set("v", tbl[1], tbl[2], opts)
end

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
vim.keymap.set(
  { "n" },
  "<leader>so",
  ':w<CR>:source %<CR>:lua vim.notify("File sourced!")<CR>',
  { desc = "[SO]urce file", silent = true }
)

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
-- copy to end of line
vim.keymap.set("n", "Y", "y$", { desc = "Yank to EOL" })
-- copy to to system clipboard (till end of line)
vim.keymap.set("n", "gY", '"+y$', { desc = "Yank to clipboard EOL" })
-- copy to system clipboard
vim.keymap.set("n", "gy", '"+y', { desc = "Yank to clipboard" })
vim.keymap.set("v", "gy", '"+y', { desc = "Yank to clipboard" })
-- copy entire file
vim.keymap.set("n", "<C-g>y", "ggyG", { desc = "Copy entire file" })
-- copy entire file to system clipboard
vim.keymap.set("n", "<C-g>Y", 'gg"+yG', { desc = "Copy Entire File To System Clipboard" })

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

-- delete all
vim.keymap.set("n", "<space>ba", ":%bdelete|edit#|bdelete# <CR>", { silent = true, desc = "Buffer Delete All" })

--- cycle through buffers
vim.keymap.set("n", "<Tab>", ":bnext <CR>", { silent = true, desc = "Next Buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprev <CR>", { silent = true, desc = "Previous Buffer" })

-- Splits
vim.keymap.set("n", "<space>vs", ":vs<CR>")
vim.keymap.set("n", "<space>hs", ":split<CR>")

-- windows
-- vim.keymap.set("n", "<leader>ww", "<C-W>p", { desc = "Other window" })
-- vim.keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete window" })
-- vim.keymap.set("n", "<leader>w-", "<C-W>s", { desc = "Split window below" })
-- vim.keymap.set("n", "<leader>w|", "<C-W>v", { desc = "Split window right" })
-- vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split window below" })
-- vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split window right" })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- highlights under cursor
if vim.fn.has("nvim-0.9.0") == 1 then
  vim.keymap.set("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
end

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

-- floating terminal
local lazyterm = function() Utils.float_term(nil, { cwd = Utils.get_root() }) end
nmap({ "<leader>ft", lazyterm, { desc = "Terminal (root dir)" } })
nmap({ "<leader>fT", function() Utils.float_term() end, { desc = "Terminal (cwd)" } })
nmap({ "<c-/>", lazyterm, { desc = "Terminal (root dir)" } })
nmap({ "<c-_>", lazyterm, { desc = "which_key_ignore" } })

-- Terminal Mappings
tmap({ "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" } })
tmap({ "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" } })
tmap({ "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" } })
tmap({ "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" } })
tmap({ "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" } })
tmap({ "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" } })
tmap({ "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" } })


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

-- M.cokeline_mappings = function()
--   nmap({ "<S-Tab>", "<Plug>(cokeline-focus-prev)", { silent = true, desc = "Prev Tab" } })
--   nmap({ "<Tab>", "<Plug>(cokeline-focus-next)", { silent = true, desc = "Next Tab" } })
-- end

M.elixir_mappings = function()
  nmap({
    "<space>fp",
    ":ElixirFromPipe<cr>",
    Utils.merge_maps(default_opts, { buffer = true, desc = "Elixir [f]rom [p]ipe" }),
  })
  nmap({
    "<space>tp",
    ":ElixirToPipe<cr>",
    Utils.merge_maps(default_opts, { buffer = true, desc = "Elixir [t]o [p]ipe" }),
  })
  vmap({
    "<space>em",
    ":ElixirExpandMacro<cr>",
    Utils.merge_maps(default_opts, { buffer = true, desc = "Elixir [e]xpand [m]acro" }),
  })
end

M.formatting_mappings = function(conform)
  vim.keymap.set({ "n", "v" }, "<leader>mp", function()
    conform.format({
      lsp_fallback = true,
      async = false,
      timeout_ms = 500,
    })
  end, { desc = "Trigger formatting (in visual mode)" })
end

M.lint_mappings = function(lint)
  nmap({
    "<leader>l",
    function()
      lint.try_lint()
    end,
    { desc = "Trigger linting for current file" },
  })
end

M.lsp_mappings = function()
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  -- gD = go Declaration
  nmap({
    "gD",
    "<cmd>lua vim.lsp.buf.declaration()<CR>",
    Utils.merge_maps(default_opts, { buffer = true, desc = "[g]o to [D]eclaration" }),
  })
  -- gD = go definition
  nmap({
    "gd",
    "<cmd>lua vim.lsp.buf.definition()<CR>",
    Utils.merge_maps(default_opts, { buffer = true, desc = "[g]o to [d]efinition" }),
  })

  -- gr = go to references
  nmap({
    "gr",
    Utils.telescope("lsp_references"),
    Utils.merge_maps(default_opts, { buffer = true, desc = "[g]o to [r]eferences" }),
  })

  -- gi = go implementation
  nmap({
    "gi",
    "<cmd>lua vim.lsp.buf.implementation()<CR>",
    Utils.merge_maps(default_opts, { buffer = true, desc = "[g]o to [i]mplementation" }),
  })
  -- fs = function signature
  nmap({
    "<leader>fs",
    "<cmd>lua vim.lsp.buf.signature_help()<CR>",
    Utils.merge_maps(default_opts, { buffer = true, desc = "[f]unction [s]ignature" }),
  })
  -- wa = workspace add
  nmap({
    "<leader>wa",
    "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>",
    Utils.merge_maps(default_opts, { buffer = true, desc = "[w]orkspace [a]dd" }),
  })
  -- D = <type> Definition
  nmap({
    "<leader>D",
    "<cmd>lua vim.lsp.buf.type_definition()<CR>",
    Utils.merge_maps(default_opts, { buffer = true, desc = "[D]efinition" }),
  })
  -- ca = code action
  nmap({
    "<leader>ca",
    "<cmd>lua vim.lsp.buf.code_action()<CR>",
    Utils.merge_maps(default_opts, { buffer = true, desc = "[c]ode [a]ctions" }),
  })
  -- K = hover doc
  nmap({
    "K",
    "<cmd>lua vim.lsp.buf.hover()<CR>",
    Utils.merge_maps(default_opts, { buffer = true, desc = "LSP hover doc" }),
  })
  -- bf = buffer format
  nmap({ "<leader>bf", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>" })
end

M.lsp_diagnostic_mappings = function()
  local function diagnostic_goto(next, severity)
    local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
    severity = severity and vim.diagnostic.severity[severity] or nil
    return function()
      go({ severity = severity })
    end
  end

  nmap({ "]d", diagnostic_goto(true), { desc = "Next Diagnostic" } })
  nmap({ "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" } })
  nmap({ "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" } })
  nmap({ "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" } })
  nmap({ "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" } })
  nmap({ "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" } })

  nmap({ "<leader>qd", "<cmd>lua vim.diagnostic.setloclist()<CR>", { desc = "Set loclist to LSP diagnostics" } })
end

M.nvimtree_mappings = function()
  nmap({ "<leader>fe", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer (find file)", silent = true } })
end

M.telescope_mappings = function()
  nmap({ "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", { desc = "Switch Buffer" } })
  nmap({ "<leader>/", Utils.telescope("live_grep"), { desc = "Grep (root dir)" } })
  nmap({ "<leader>:", "<cmd>Telescope command_history<cr>", { desc = "Command History" } })
  nmap({ "<leader><space>", Utils.telescope("files"), { desc = "Find Files (root dir)" } })
  -- find
  nmap({ "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" } })
  nmap({ "<leader>ff", Utils.telescope("files"), { desc = "Find Files (root dir)" } })
  nmap({ "<leader>fF", Utils.telescope("files", { cwd = false }), { desc = "Find Files (cwd)" } })
  nmap({ "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent" } })
  nmap({ "<leader>fR", Utils.telescope("oldfiles", { cwd = vim.loop.cwd() }), { desc = "Recent (cwd)" } })
  -- git
  nmap({ "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "commits" } })
  nmap({ "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "status" } })
  -- search
  nmap({ "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Buffer" } })
  nmap({ "<leader>sc", "<cmd>Telescope command_history<cr>", { desc = "Command History" } })
  nmap({ "<leader>sC", "<cmd>Telescope commands<cr>", { desc = "Commands" } })
  nmap({ "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Document diagnostics" } })
  nmap({ "<leader>sD", "<cmd>Telescope diagnostics<cr>", { desc = "Workspace diagnostics" } })
  nmap({ "<leader>sg", Utils.telescope("live_grep"), { desc = "Grep (root dir)" } })
  nmap({ "<leader>sG", Utils.telescope("live_grep", { cwd = false }), { desc = "Grep (cwd)" } })
  nmap({ "<leader>sh", "<cmd>Telescope help_tags<cr>", { desc = "Help Pages" } })
  nmap({ "<leader>sk", "<cmd>Telescope keymaps<cr>", { desc = "Key Maps" } })
end

M.git_conflict_mappings = function()
  vim.keymap.set("n", "co", "<Plug>(git-conflict-ours)")
  vim.keymap.set("n", "ct", "<Plug>(git-conflict-theirs)")
  vim.keymap.set("n", "cb", "<Plug>(git-conflict-both)")
  vim.keymap.set("n", "c0", "<Plug>(git-conflict-none)")
  vim.keymap.set("n", "]x", "<Plug>(git-conflict-prev-conflict)")
  vim.keymap.set("n", "[x", "<Plug>(git-conflict-next-conflict)")
end

M.silicon_mappings = function()
  vmap({
    "<leader>ss",
    function()
      require("silicon").visualise_api({ to_clip = true })
    end,
    { silent = true, desc = "Screenshot a code snippet to clipboard" },
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

M.vim_test_mappings = {
  { "<leader>tn", ":TestNearest<CR>", silent = true, desc = "[T]est [N]earest" },
  { "<leader>tf", ":TestFile<CR>",    silent = true, desc = "[T]est [F]ile" },
  { "<leader>ts", ":TestSuite<CR>",   silent = true, desc = "[T]est [S]uite" },
  { "<leader>tl", ":TestLast<CR>",    silent = true, desc = "[T]est [L]ast" },
}

return M
