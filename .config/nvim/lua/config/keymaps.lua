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
local default_opts = { noremap = true, silent = true }

local map = function(tbl)
  local opts = tbl[4] and vim.tbl_deep_extend("force", default_opts, tbl[4]) or default_opts
  vim.keymap.set(tbl[1], tbl[2], tbl[3], opts)
end

local nmap = function(tbl)
  local opts = tbl[3] and vim.tbl_deep_extend("force", default_opts, tbl[3]) or default_opts
  vim.keymap.set("n", tbl[1], tbl[2], opts)
end

local vmap = function(tbl)
  local opts = tbl[3] and vim.tbl_deep_extend("force", default_opts, tbl[3]) or default_opts
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

local picker = function(fun, opts)
  if opts == nil then
    opts = {}
  end

  return function()
    Snacks.picker[fun](opts)
  end
end

local git_copy_file_url = function()
  ---@diagnostic disable-next-line: missing-fields
  Snacks.gitbrowse {
    open = function(url)
      -- gitbrowse doesn't support file link without lines, so I'm setting the
      -- line range to 0-0 and stripping it before copying to sys clipboard
      url = url:gsub("#L0%-L0$", "")
      vim.fn.setreg("+", url)
    end,
    notify = false,
    line_start = 0,
    line_end = 0,
  }
  vim.notify("Copied " .. vim.fn.getreg "+", vim.log.levels.INFO)
end

local git_copy_line_url = function()
  ---@diagnostic disable-next-line: missing-fields
  Snacks.gitbrowse {
    open = function(url)
      vim.fn.setreg("+", url)
    end,
    notify = false,
  }
  vim.notify(vim.fn.getreg "+", vim.log.levels.INFO, { title = "Copied" })
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

vim.keymap.set("n", "<Leader>cp", function()
  vim.cmd "let @+ = expand('%')"
end, { desc = "Copy relative path" })

-- Search
vim.keymap.set({ "n", "x" }, "gw", "*N", { desc = "Search word under cursor" })
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

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
  nmap { "<leader>an", attempt.new_select, vim.tbl_deep_extend("force", default_opts, { desc = "New Attempt" }) }
  -- run current attempt buffer
  nmap { "<leader>ar", attempt.run, vim.tbl_deep_extend("force", default_opts, { desc = "Run Attempt" }) }
  -- delete attempt from current buffer
  nmap { "<leader>ad", attempt.delete_buf, vim.tbl_deep_extend("force", default_opts, { desc = "Delete Attempt" }) }
  -- rename attempt from current buffer
  nmap { "<leader>ac", attempt.rename_buf, vim.tbl_deep_extend("force", default_opts, { desc = "Rename Attempt" }) }
  -- open one of the existing scratch buffers
  nmap { "<leader>al", attempt.open_select, vim.tbl_deep_extend("force", default_opts, { desc = "Select Attempt" }) }
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

M.lsp_mappings = function()
  nmap {
    "gd",
    function()
      Snacks.picker.lsp_definitions()
    end,
    { buffer = true, desc = "Go to Definition" },
  }

  nmap {
    "gr",
    function()
      Snacks.picker.lsp_references()
    end,
    { desc = "Go to References", nowait = true },
  }

  nmap {
    "gI",
    function()
      Snacks.picker.lsp_implementations()
    end,
    { desc = "Go to Implementation", buffer = true },
  }
  nmap {
    "<leader>D",
    function()
      Snacks.picker.lsp_type_definitions()
    end,
    { desc = "Go to Type Definition", buffer = true },
  }
  nmap {
    "gD",
    function()
      Snacks.picker.lsp_declarations()
    end,
    { desc = "Goto Declaration", buffer = true },
  }
  map { { "n", "v" }, "<leader>ca", "<cmd>Lspsaga code_action<CR>", { buffer = true, desc = "[C]ode [A]ction" } }
  nmap { "K", vim.lsp.buf.hover, { buffer = true, desc = "LSP Hover Doc" } }
  nmap { "<leader>rn", vim.lsp.buf.rename, { buffer = true, desc = "[R]e[n]ame Symbol Under Cursor" } }
  nmap {
    "<leader>th",
    function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { buffer = true })
    end,
    { desc = "LSP: [T]oggle Inlay [H]ints", noremap = true, silent = true, buffer = true },
  }
  nmap {
    "<leader>fm",
    function()
      vim.lsp.buf.format { async = true }
    end,
    { desc = "LSP: [f]or[m]at", noremap = true, silent = true, buffer = true },
  }
  nmap {
    "<leader>cc",
    picker("pick", require "plugins.snacks.conventional_commits_picker"),
    { desc = "[C]onventional [C]ommits" },
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

-- M.lsp_inlay_hints_mappings = function(buf)
--   nmap {
--     "<leader>th",
--     function()
--       vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf })
--     end,
--     { desc = "LSP: [T]oggle Inlay [H]ints", noremap = true, silent = true, buffer = buf },
--   }
-- end

M.vim_test_mappings = function()
  nmap { "<leader>tn", ":TestNearest<CR>", { desc = "Test Nearest" } }
  nmap { "<leader>tf", ":TestFile<CR>", { desc = "Test File" } }
  nmap { "<leader>ts", ":TestSuite<CR>", { desc = "Test Suite" } }
  nmap { "<leader>tl", ":TestLast<CR>", { desc = "Test Last" } }
end

M.telescope_mappings = {
  { "<leader>f?", telescope "search_history",   desc = "Search History" },
  { "<leader>fh", telescope "help_tags",        desc = "[F]ind [H]elp" },
  { "<leader>fO", telescope "vim_options",      desc = "[F]ind [O]ptions" },

  --  Extensions
  { "<leader>bb", telescope "buffers",          desc = "Find Buffers" },

  -- better spell suggestions
  { "z=",         telescope "spell_suggest",    desc = "Spelling Suggestions" },

  -- search unicode symbols 
  { "<leader>fu", "<cmd>Telescope symbols<cr>", desc = "[F]ind [U]nicode" },
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
    "<leader>st",
    function()
      Snacks.picker.todo_comments()
    end,
    desc = "Todo",
  },
  {
    "<leader>sT",
    function()
      Snacks.picker.todo_comments { keywords = { "TODO", "FIX", "FIXME" } }
    end,
    desc = "Todo/Fix/Fixme",
  },
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
    { desc = "[T]est Show Output" },
  }
  nmap {
    "<leader>tO",
    function()
      require("neotest").output_panel.toggle()
    end,
    { desc = "[T]est Toggle Output Panel" },
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
  {
    "<leader>e",
    function()
      Snacks.explorer.open {
        auto_close = true,
        layout = { layout = { position = "right" } },
        include = { ".*" },
      }
    end,
    desc = "Open explorer",
  },
  --------------
  -- Grep
  --------------
  {
    "<leader>/",
    function()
      Snacks.picker.grep {
        hidden = true,
      }
    end,
    desc = "Grep",
  },
  {
    "<leader>sw",
    function()
      Snacks.picker.grep_word { hidden = true }
    end,
    desc = "Visual selection or word",
    mode = { "n", "x" },
  },
  --------------
  -- Terminal
  --------------
  {
    "<leader>tt",
    function()
      Snacks.terminal(nil, {
        win = {
          style = "float",
          title = "Terminal",
          width = 0.9,
          height = 0.8,
          border = "rounded",
        },
        env = {
          -- Ensure we're in the correct directory
          PWD = vim.fn.getcwd(),
        },
      })
    end,
    desc = "Toggle Terminal",
    mode = { "n", "t", "v" },
  },

  --------------
  -- Find
  --------------
  {
    "<leader>fr",
    function()
      Snacks.picker.recent()
    end,
    desc = "Recent",
  },
  {
    "<leader>ff",
    function()
      Snacks.picker.files { hidden = true }
    end,
    desc = "Find Files",
  },
  { "<leader>fp", picker "pr_files", desc = "[F]ind [P]R files" },
  {
    "<leader>fg",
    function()
      Snacks.picker.git_files()
    end,
    desc = "Find Files (git-files)",
  },

  --------------
  -- Search
  --------------
  {
    "<leader>sm",
    function()
      Snacks.picker.marks()
    end,
    desc = "Marks",
  },
  {
    "<leader>sk",
    function()
      Snacks.picker.keymaps()
    end,
    desc = "Keymaps",
  },
  {
    "<leader>sc",
    function()
      Snacks.picker.command_history()
    end,
    desc = "Command History",
  },
  {
    "<leader>sC",
    function()
      Snacks.picker.commands()
    end,
    desc = "Commands",
  },
  {
    "<leader>sb",
    function()
      Snacks.picker.lines()
    end,
    desc = "Buffer Lines",
  },
  {
    "<leader>sw",
    function()
      Snacks.picker.grep_word()
    end,
    desc = "Visual selection or word",
    mode = { "n", "x" },
  },
  {
    "<leader>pp",
    function()
      Snacks.picker.registers()
    end,
    desc = "Registers",
  },

  -- Git

  {
    "<leader>gc",
    function()
      Snacks.picker.git_log()
    end,
    desc = "Git Log",
  },
  {
    "<leader>gs",
    function()
      Snacks.picker.git_status()
    end,
    desc = "Git Status",
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
    mode = { "n", "v" },
  },
  { "<leader>gY", git_copy_file_url, mode = { "n", "x" },       desc = "Git Copy File URL" },
  { "<leader>gy", git_copy_line_url, mode = { "n", "x" },       desc = "Git Copy Line(s) URL" },
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

  --------------
  -- Buffer
  --------------

  { "<Tab>",   "<cmd>bnext<CR>", desc = "Next buffer" },
  { "<S-Tab>", "<cmd>bprev<CR>", desc = "Previous buffer" },
  {
    "<leader>,",
    function()
      Snacks.picker.buffers()
    end,
    desc = "Buffers",
  },
  {
    "<leader>bd",
    function()
      Snacks.bufdelete { force = true }
    end,
    desc = "Delete Buffer (Force)",
  },
  {
    "<leader>bo",
    function()
      Snacks.bufdelete.other { force = true }
    end,
    desc = "Delete Other Buffers (Force)",
  },

  --------------
  -- Words
  --------------

  {
    "]]",
    function()
      Snacks.words.jump(vim.v.count1)
    end,
    desc = "Next Reference",
  },
  {
    "[[",
    function()
      Snacks.words.jump(-vim.v.count1)
    end,
    desc = "Prev Reference",
  },

  --------------
  -- Notification
  --------------

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

  --------------
  -- Scratch
  --------------

  {
    "<leader>.",
    function()
      Snacks.scratch()
    end,
    desc = "Toggle Scratch Buffer",
  },
  {
    "<leader>S",
    function()
      Snacks.scratch.select()
    end,
    desc = "Select Scratch Buffer",
  },
}

M.sort_mappings = {
  { "go",   ":Sort<CR>",    mode = "v", desc = "Order (sort lines/line params)" },
  { "goi'", "vi':Sort<CR>", mode = "n", desc = "Order in [']" },
  { "goi(", "vi(:Sort<CR>", mode = "n", desc = "Order in (" },
  { "goi[", "vi[:Sort<CR>", mode = "n", desc = "Order in [" },
  { "goip", "vip:Sort<CR>", mode = "n", desc = "Order in [p]aragraph" },
  { "goi{", "vi{:Sort<CR>", mode = "n", desc = "Order in {" },
  { 'goi"', 'vi":Sort<CR>', mode = "n", desc = 'Order in ["]' },
}

M.tabby_mappings = {
  { "<leader>ta", ":$tabnew<CR>",  mode = "n", desc = "Tab new",      noremap = true },
  { "<leader>tc", ":tabclose<CR>", mode = "n", desc = "Tab [c]lose",  noremap = true },
  { "<leader>to", ":tabonly<CR>",  mode = "n", desc = "Tab only",     noremap = true },
  { "<leader>tl", ":tabn<CR>",     mode = "n", desc = "Tab next",     noremap = true },
  { "<leader>th", ":tabp<CR>",     mode = "n", desc = "Tab previous", noremap = true },
}

-- Jest Test Runner with Snacks Terminal
M.jest_test_mappings = function()
  local function run_jest_test()
    local current_file = vim.fn.expand "%:p"
    local filename = vim.fn.expand "%:t"

    -- Check if current file is a test file
    if not filename:match "%.test%.js$" then
      vim.notify("Current file is not a Jest test file (.test.js)", vim.log.levels.WARN)
      return
    end

    -- Get relative path from project root
    local relative_path = vim.fn.expand "%:."

    -- Create the Jest command with read to keep terminal open
    local jest_cmd = string.format(
      "clear && yarn test:dev --config jest.angular.config.js %s; read -p 'Press Enter to close...'",
      relative_path
    )

    -- Run in Snacks terminal with floating window
    Snacks.terminal(jest_cmd, {
      win = {
        style = "float",
        title = "Jest Test: " .. filename,
        width = 0.9,
        height = 0.8,
        border = "rounded",
      },
      env = {
        -- Ensure we're in the correct directory
        PWD = vim.fn.getcwd(),
      },
    })
  end

  nmap {
    "<leader>tj",
    run_jest_test,
    { desc = "[T]est [J]est - Run current file" },
  }
end

-- Initialize Jest test mappings
M.jest_test_mappings()

return M
