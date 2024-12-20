local M = {}
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

--- returns a function that calls the specified telescope builtin
local telescope = function(fun, opts)
  if opts == nil then
    opts = {}
  end

  return function()
    require("telescope.builtin")[fun](opts)
  end
end

-- ================================
-- # Misc
-- ================================
-- quit all
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
vim.keymap.set("n", "<space>wq", ":wq <CR>", { silent = true, desc = "Save and Quit" })

-- command
vim.keymap.set("n", ";", ":")

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
vim.keymap.set("n", "<leader>uw", function()
  TOGGLE.option "wrap"
end, { desc = "Toggle Word Wrap" })

vim.keymap.set("n", "<leader>ud", TOGGLE.diagnostics, { desc = "Toggle Diagnostics" })

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

  nmap { "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "Next Diagnostic" } }
  nmap { "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "Prev Diagnostic" } }
  nmap { "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" } }
  nmap { "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" } }
  nmap { "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" } }
  nmap { "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" } }

  nmap { "<leader>qd", "<cmd>lua vim.diagnostic.setloclist()<CR>", { desc = "Set loclist to LSP diagnostics" } }
end

M.lsp_mappings = function(buf)
  nmap { "K", "<cmd>Lspsaga hover_doc ++quiet<CR>", { desc = "LSP: Hover", buffer = buf } }
  nmap { "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "LSP: [C]ode [A]ction", buffer = buf } }
  nmap { "<leader>rn", "<cmd>Lspsaga rename<CR>", { desc = "LSP: [R]e[n]ame", buffer = buf } }
  nmap { "gd", require("telescope.builtin").lsp_definitions, { desc = "LSP: [G]oto [D]efinition", buffer = buf } }
  nmap { "gr", require("telescope.builtin").lsp_references, { desc = "LSP: [G]oto [R]eferences", buffer = buf } }
  nmap { "gI", require("telescope.builtin").lsp_implementations, { desc = "LSP: [G]oto [I]mplementation", buffer = buf } }
  nmap {
    "<leader>D",
    require("telescope.builtin").lsp_type_definitions,
    { desc = "LSP: Type [D]efinition", buffer = buf },
  }
  nmap {
    "<leader>ds",
    require("telescope.builtin").lsp_document_symbols,
    { desc = "LSP: [D]ocument [S]ymbols", buffer = buf },
  }
  nmap {
    "<leader>ws",
    require("telescope.builtin").lsp_dynamic_workspace_symbols,
    { desc = "LSP: [W]orkspace [S]ymbols", buffer = buf },
  }
  nmap { "gD", vim.lsp.buf.declaration, { desc = "LSP: [G]oto [D]eclaration", buffer = buf } }
  nmap {
    "<leader>th",
    function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf })
    end,
    { desc = "LSP: [T]oggle Inlay [H]ints", buffer = buf },
  }
  nmap {
    "<leader>fm",
    function()
      vim.lsp.buf.format { async = true }
    end,
    { desc = "LSP: [f]or[m]at", buffer = buf },
  }
end

M.lsp_inlay_hints_mappings = function(buf)
  nmap {
    "<leader>th",
    function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf })
    end,
    { desc = "LSP: [T]oggle Inlay [H]ints", buffer = buf },
  }
end

M.vim_test_mappings = function()
  nmap { "<leader>tn", ":TestNearest<CR>", { desc = "[T]est [N]earest" } }
  nmap { "<leader>tf", ":TestFile<CR>", { desc = "[T]est [F]ile" } }
  nmap { "<leader>ts", ":TestSuite<CR>", { desc = "[T]est [S]uite" } }
  nmap { "<leader>tl", ":TestLast<CR>", { desc = "[T]est [L]ast" } }
end

M.telescope_mappings = {
  -- muscle memory
  { "<C-p>", telescope "find_files", default_opts },
  { "<C-b>", telescope "buffers", default_opts },

  -- Compatible with hydra setup
  { "<leader>f/", telescope "current_buffer_fuzzy_find", desc = "Buffer fuzzy find" },
  { "<leader>f:", telescope "commands", desc = "Command search" },
  { "<leader>f;", telescope "command_history", desc = "Command History" },
  { "<leader>f?", telescope "search_history", desc = "Search History" },
  { "<leader>ff", telescope "find_files", desc = "[F]ind [F]iles" },
  { "<leader>fg", telescope "live_grep", desc = "[F]ind w/ [G]rep" },
  { "<leader>fh", telescope "help_tags", desc = "[F]ind [H]elp" },
  { "<leader>fk", telescope "keymaps", desc = "[F]ind [K]eymaps" },
  { "<leader>fo", telescope "oldfiles", desc = "[F]ind [o]ld files" },
  { "<leader>fO", telescope "vim_options", desc = "[F]ind [O]ptions" },
  { "<leader>fr", "<cmd>Telescope frecency workspace=CWD<CR>", desc = "[F][R]ecency" },
  { "<leader>fd", require("plugins.telescope.setup").find_dotfiles, desc = "[F]ind [D]otfiles" },
  { "<leader>fs", telescope "git_status", desc = "[F]ind (Git) [S]tatus" },
  { "<leader>fw", telescope "grep_string", desc = "[F]ind [W]ord" },

  --  Extensions
  { "<leader>fb", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", desc = "[F]ile [B]rowser" },

  { "<leader>lg", telescope "live_grep", desc = "[L]ive [G]rep" },
  { "<leader>bb", telescope "buffers", desc = "Find Buffers" },

  -- better spell suggestions
  { "z=", telescope "spell_suggest", desc = "Spelling Suggestions" },

  -- Git
  -- bc = buffer commits (like gitv!)
  { "<leader>bc", telescope "git_bcommits", desc = "[B]uffer [C]ommits" },

  -- LSP
  -- ds = document symbols
  { "<leader>ds", telescope "lsp_document_symbols", desc = "[D]ocument [S]ymbols" },

  { "<leader>cc", "<cmd>Telescope conventional_commits<cr>", desc = "[C]onventional [C]ommits" },

  -- search unicode symbols 
  { "<leader>fu", "<cmd>Telescope symbols<cr>", desc = "[F]ind [U]nicode" },
  {
    "<C-q>",
    "<cmd>Telescope symbols<cr>",
    mode = "i",
    desc = "[F]ind [U]nicode",
  },
}

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

M.neo_test_mappings = function()
  nmap {
    "<leader>tt",
    function()
      require("neotest").run.run(vim.fn.expand "%")
    end,
    { desc = "[T]est Run File" },
  }
  nmap {
    "<leader>tT",
    function()
      require("neotest").run.run(vim.uv.cwd())
    end,
    { desc = "[T]est Run All [T]est Files" },
  }
  nmap {
    "<leader>tr",
    function()
      require("neotest").run.run()
    end,
    { desc = "[T]est [R]un Nearest" },
  }
  nmap {
    "<leader>tl",
    function()
      require("neotest").run.run_last()
    end,
    { desc = "[T]est Run [L]ast" },
  }
  nmap {
    "<leader>ts",
    function()
      require("neotest").summary.toggle()
    end,
    { desc = "[T]est Toggle [S]ummary" },
  }
  nmap {
    "<leader>to",
    function()
      require("neotest").output.open { enter = true, auto_close = true }
    end,
    { desc = "[T]est Show [O]utput" },
  }
  nmap {
    "<leader>tO",
    function()
      require("neotest").output_panel.toggle()
    end,
    { desc = "[T]est Toggle [O]utput Panel" },
  }
  nmap {
    "<leader>tS",
    function()
      require("neotest").run.stop()
    end,
    { desc = "[T]est [S]top" },
  }
  nmap {
    "<leader>tw",
    function()
      require("neotest").watch.toggle(vim.fn.expand "%")
    end,
    { desc = "[T]est Toggle [W]atch" },
  }
end

M.snacks_mappings = {
  { "<Tab>", "<cmd>bnext<CR>", desc = "Next buffer" },
  { "<S-Tab>", "<cmd>bprev<CR>", desc = "Previous buffer" },
  {
    "]]",
    function()
      Snacks.words.jump(vim.v.count1)
    end,
    desc = "Next Reference",
    mode = { "n", "t" },
  },
  {
    "[[",
    function()
      Snacks.words.jump(-vim.v.count1)
    end,
    desc = "Prev Reference",
  },
  {
    "<leader>nd",
    function()
      Snacks.notifier.hide()
    end,
    desc = "Notification Dismiss",
  },
  {
    "<leader>un",
    function()
      Snacks.notifier.hide()
    end,
    desc = "Dismiss All Notifications",
  },
  {
    "<leader>bd",
    function()
      Snacks.bufdelete()
    end,
    desc = "Delete Buffer",
  },
  {
    "<leader>bD",
    function()
      Snacks.bufdelete { force = true }
    end,
    desc = "Delete Buffer (Force)",
  },
  {
    "<leader>bo",
    function()
      Snacks.bufdelete.other()
    end,
    desc = "Delete Other Buffers",
  },
  {
    "<leader>bO",
    function()
      Snacks.bufdelete.other { force = true }
    end,
    desc = "Delete Other Buffers (Force)",
  },
  {
    "<leader>gg",
    function()
      Snacks.lazygit()
    end,
    desc = "Lazygit",
  },
  {
    "<leader>bl",
    function()
      Snacks.git.blame_line()
    end,
    desc = "Git Blame Line",
  },
  {
    "<leader>gB",
    function()
      Snacks.gitbrowse()
    end,
    desc = "Git Browse",
  },
  {
    "<leader>gf",
    function()
      Snacks.lazygit.log_file()
    end,
    desc = "Lazygit Current File History",
  },
  {
    "<leader>gl",
    function()
      Snacks.lazygit.log()
    end,
    desc = "Lazygit Log (cwd)",
  },
  {
    "<leader>rf",
    function()
      Snacks.rename.rename_file()
    end,
    desc = "Rename File",
  },
  {
    "<c-/>",
    function()
      Snacks.terminal()
    end,
    desc = "Toggle Terminal",
  },
  {
    "]r",
    function()
      Snacks.words.jump(vim.v.count1)
    end,
    desc = "Next Reference",
  },
  {
    "[r",
    function()
      Snacks.words.jump(-vim.v.count1)
    end,
    desc = "Prev Reference",
  },
}

M.sort_mappings = {
  { "go", ":Sort<CR>", mode = "v", desc = "(go) Order (sort lines/line params)" },
  { "goi'", "vi':Sort<CR>", mode = "n", desc = "(go) [O]rder [i]n [']" },
  { "goi(", "vi(:Sort<CR>", mode = "n", desc = "(go) [O]rder [i]n (" },
  { "goi[", "vi[:Sort<CR>", mode = "n", desc = "(go) [O]rder [i]n [" },
  { "goip", "vip:Sort<CR>", mode = "n", desc = "(go) [O]rder [i]n [p]aragraph" },
  { "goi{", "vi{:Sort<CR>", mode = "n", desc = "(go) [O]rder [i]n {" },
  { 'goi"', 'vi":Sort<CR>', mode = "n", desc = '(go) [O]rder [i]n ["]' },
}

M.tabby_mappings = {
  { "<leader>ta", ":$tabnew<CR>", mode = "n", desc = "[T]ab new", noremap = true },
  { "<leader>tc", ":tabclose<CR>", mode = "n", desc = "[T]ab [c]lose", noremap = true },
  { "<leader>to", ":tabonly<CR>", mode = "n", desc = "[T]ab [o]nly", noremap = true },
  { "<leader>tl", ":tabn<CR>", mode = "n", desc = "[T]ab [n]ext", noremap = true },
  { "<leader>th", ":tabp<CR>", mode = "n", desc = "[T]ab [p]revious", noremap = true },
}

return M
