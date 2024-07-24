local M = {}
local TELESCOPE = require "config.utils.telescope"
local TOGGLE = require "config.utils.toggle"
local UTILS = require "config.utils"

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
local default_opts = { noremap = true, silent = true }

local nmap = function(tbl)
  local opts = tbl[3] and UTILS.merge_maps(default_opts, tbl[3]) or default_opts
  vim.keymap.set("n", tbl[1], tbl[2], opts)
end

local vmap = function(tbl)
  local opts = tbl[3] and UTILS.merge_maps(default_opts, tbl[3]) or default_opts
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
  TOGGLE.option "spell"
end, { desc = "Toggle Spelling" })

vim.keymap.set("n", "<leader>uw", function()
  TOGGLE.option "wrap"
end, { desc = "Toggle Word Wrap" })

vim.keymap.set("n", "<leader>ul", function()
  TOGGLE.option("relativenumber", true)
  TOGGLE.option "number"
end, { desc = "Toggle Line Numbers" })

vim.keymap.set("n", "<leader>ud", TOGGLE.diagnostics, { desc = "Toggle Diagnostics" })
local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3

vim.keymap.set("n", "<leader>uc", function()
  TOGGLE.option("conceallevel", false, { 0, conceallevel })
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
  vim.cmd "let @+ = expand('%')"
end, { desc = "Copy relative path" })

-- Search
vim.keymap.set({ "n", "x" }, "gw", "*N", { desc = "Search word under cursor" })
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Buffers
vim.keymap.set("n", "<space>ba", ":%bdelete|edit#|bdelete# <CR>", { silent = true, desc = "Buffer Delete All" })
-- vim.keymap.set("n", "<Tab>", ":bnext <CR>", { silent = true, desc = "Next Buffer" })
-- vim.keymap.set("n", "<S-Tab>", ":bprev <CR>", { silent = true, desc = "Previous Buffer" })

-- Splits
vim.keymap.set("n", "<space>vs", ":vs<CR>")
vim.keymap.set("n", "<space>hs", ":split<CR>")

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Surround
vim.keymap.set("n", "<Leader>sq", function()
  vim.cmd [[%s/^\(.*\)$/'\1',/]]
end, { silent = true })
vim.keymap.set("n", "<Leader>sQ", function()
  vim.cmd [[%s/^\(.*\)$/"\1",/]]
end, { silent = true })
vim.keymap.set("n", "<Leader>s,", function()
  vim.cmd [[%s/^\(.*\)$/\1,/]]
end, { silent = true })

-- LSP Restart
nmap { "<leader>lr", "<cmd>LspRestart<CR>", { desc = "LSP restart" } }
-- ================================

M.attempt_mappings = function(attempt)
  -- new attempt, selecting extension
  nmap { "<leader>an", attempt.new_select, UTILS.merge_maps(default_opts, { desc = "New Attempt" }) }
  -- run current attempt buffer
  nmap { "<leader>ar", attempt.run, UTILS.merge_maps(default_opts, { desc = "Run Attempt" }) }
  -- delete attempt from current buffer
  nmap { "<leader>ad", attempt.delete_buf, UTILS.merge_maps(default_opts, { desc = "Delete Attempt" }) }
  -- rename attempt from current buffer
  nmap { "<leader>ac", attempt.rename_buf, UTILS.merge_maps(default_opts, { desc = "Rename Attempt" }) }
  -- open one of the existing scratch buffers
  nmap { "<leader>al", attempt.open_select, UTILS.merge_maps(default_opts, { desc = "Select Attempt" }) }
end

M.elixir_mappings = function()
  nmap {
    "<space>fp",
    ":ElixirFromPipe<cr>",
    UTILS.merge_maps(default_opts, { buffer = true, desc = "Elixir [f]rom [p]ipe" }),
  }
  nmap {
    "<space>tp",
    ":ElixirToPipe<cr>",
    UTILS.merge_maps(default_opts, { buffer = true, desc = "Elixir [t]o [p]ipe" }),
  }
  vmap {
    "<space>em",
    ":ElixirExpandMacro<cr>",
    UTILS.merge_maps(default_opts, { buffer = true, desc = "Elixir [e]xpand [m]acro" }),
  }
end

M.formatting_mappings = function(conform)
  vim.keymap.set({ "n", "v" }, "<leader>mp", function()
    conform.format {
      lsp_fallback = true,
      async = false,
      timeout_ms = 500,
    }
  end, { desc = "Trigger formatting (in visual mode)" })
end

M.harpoon_mappings = function()
  nmap { "<s-m>", "<cmd>lua require('user.harpoon').mark_file()<cr>", default_opts }
  nmap { "<TAB>", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", default_opts }
end

M.inc_rename = function()
  nmap {
    "<leader>rn",
    function()
      return ":IncRename " .. vim.fn.expand "<cword>"
    end,
    { expr = true },
  }
end

M.lint_mappings = function(lint)
  nmap {
    "<leader>l",
    function()
      lint.try_lint()
    end,
    { desc = "Trigger linting for current file" },
  }
end

M.lsp_diagnostic_mappings = function()
  local function diagnostic_goto(next, severity)
    local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
    severity = severity and vim.diagnostic.severity[severity] or nil
    return function()
      go { severity = severity }
    end
  end

  nmap { "]d", diagnostic_goto(true), { desc = "Next Diagnostic" } }
  nmap { "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" } }
  nmap { "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" } }
  nmap { "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" } }
  nmap { "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" } }
  nmap { "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" } }

  nmap { "<leader>qd", "<cmd>lua vim.diagnostic.setloclist()<CR>", { desc = "Set loclist to LSP diagnostics" } }
end

M.lsp_mappings = function()
  local opts = { buffer = 0 }
  local builtin = require "telescope.builtin"

  vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
  nmap { "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts }
  nmap { "gd", builtin.lsp_definitions, opts }
  nmap { "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts }
  nmap { "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts }
  nmap { "gr", builtin.lsp_references, opts }
  nmap { "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts }
  nmap { "fs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts }
  nmap { "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts }
  nmap { "<leader>bf", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts }
  nmap { "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts }
  nmap { "<leader>li", "<cmd>LspInfo<cr>", opts }
  nmap { "<leader>lr", "<cmd>LspRestart<cr>", opts }
end

M.vim_test_mappings = function()
  nmap { "<leader>tn", ":TestNearest<CR>", { desc = "[T]est [N]earest" } }
  nmap { "<leader>tf", ":TestFile<CR>", { desc = "[T]est [F]ile" } }
  nmap { "<leader>ts", ":TestSuite<CR>", { desc = "[T]est [S]uite" } }
  nmap { "<leader>tl", ":TestLast<CR>", { desc = "[T]est [L]ast" } }
end

M.telescope_mappings = function()
  nmap { "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", { desc = "Switch Buffer" } }
  nmap { "<leader>/", TELESCOPE.telescope "live_grep", { desc = "Grep (root dir)" } }
  nmap { "<leader>:", "<cmd>Telescope command_history<cr>", { desc = "Command History" } }
  nmap { "<leader><space>", TELESCOPE.telescope "files", { desc = "Find Files (root dir)" } }
  -- find
  nmap { "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" } }
  nmap { "<leader>ff", TELESCOPE.telescope("files", { cwd = false }), { desc = "Find Files (root dir)" } }
  nmap { "<leader>fF", TELESCOPE.telescope "files", { desc = "Find Files (cwd)" } }
  nmap { "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent" } }
  nmap { "<leader>fR", TELESCOPE.telescope("oldfiles", { cwd = vim.loop.cwd() }), { desc = "Recent (cwd)" } }
  -- git
  nmap { "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "commits" } }
  nmap { "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "status" } }
  -- search
  nmap { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Buffer" } }
  nmap { "<leader>sc", "<cmd>Telescope command_history<cr>", { desc = "Command History" } }
  nmap { "<leader>sC", "<cmd>Telescope commands<cr>", { desc = "Commands" } }
  nmap { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", { desc = "Document diagnostics" } }
  nmap { "<leader>sD", "<cmd>Telescope diagnostics<cr>", { desc = "Workspace diagnostics" } }
  nmap { "<leader>sg", TELESCOPE.telescope "live_grep", { desc = "Grep (root dir)" } }
  nmap { "<leader>sG", TELESCOPE.telescope("live_grep", { cwd = false }), { desc = "Grep (cwd)" } }
  nmap { "<leader>sh", "<cmd>Telescope help_tags<cr>", { desc = "Help Pages" } }
  nmap { "<leader>sk", "<cmd>Telescope keymaps<cr>", { desc = "Key Maps" } }
  nmap { "<leader>sw", TELESCOPE.telescope("grep_string", { word_match = "-w" }), { desc = "Word (root dir)" } }
  nmap { "<leader>sW", TELESCOPE.telescope("grep_string", { cwd = false, word_match = "-w" }), { desc = "Word (cwd)" } }
  vmap { "<leader>sw", TELESCOPE.telescope "grep_string", { desc = "Selection (root dir)" } }
  vmap { "<leader>sW", TELESCOPE.telescope("grep_string", { cwd = false }), { desc = "Selection (cwd)" } }
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
  vmap {
    "<leader>ss",
    function()
      require("silicon").visualise_api { to_clip = true }
    end,
    { silent = true, desc = "Screenshot a code snippet to clipboard" },
  }
end

M.oil_mappings = function()
  nmap { "-", "<cmd>Oil<CR>", { desc = "Open parent directory" } }
  nmap {
    "<leader>-",
    function()
      require("oil").toggle_float()
    end,
    { desc = "Open parent directory (float)" },
  }
end

M.trouble_mappings = function(trouble)
  nmap { "<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Workspace Diagnostics" } }
  nmap { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Document Diagnostics" } }
  nmap { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Open Loclist" } }
  nmap { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Open Quickfix" } }
  nmap { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" } }
  nmap {
    "<leader>cl",
    "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
    { desc = "LSP Definitions / references / ... (Trouble)" },
  }
  -- smart `[q` and `]q` mappings that work for both qf list and trouble
  nmap {
    "[q",
    function()
      if trouble.is_open() then
        trouble.prev { skip_groups = true, jump = true }
      else
        local ok, err = pcall(vim.cmd.cprev)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end
    end,
    { desc = "Previous trouble/quickfix item" },
  }
  nmap {
    "]q",
    function()
      if trouble.is_open() then
        trouble.next { skip_groups = true, jump = true }
      else
        local ok, err = pcall(vim.cmd.cnext)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end
    end,
    { desc = "Next trouble/quickfix item" },
  }
  nmap { "gR", "<cmd>Trouble lsp_references<cr>", { desc = "[G]o to [R]eferences (Trouble)" } }
end

M.todo_comments_mappings = {
  {
    "]t",
    function()
      require("todo-comments").jump_next()
    end,
    desc = "Next todo comment",
  },
  {
    "[t",
    function()
      require("todo-comments").jump_prev()
    end,
    desc = "Previous todo comment",
  },
  { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
  { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
}

return M
