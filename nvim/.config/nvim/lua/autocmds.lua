-- put global event listeners here

local augroup = require("utils").augroup

-- Check if we need to reload the file when it changed
augroup("CheckTime", {
  {
    event = { "FocusGained", "TermClose", "TermLeave" },
    command = "checktime",
  },
})

-- automatic spell check for some file types
augroup("SetSpell", {
  {
    event = { "BufRead", "BufNewFile" },
    pattern = { "*.txt", "*.md", "*.tex" },
    command = "setlocal spell",
  },
  {
    event = { "FileType" },
    pattern = { "gitcommit" },
    command = "setlocal spell",
  },
})

augroup("Firenvim", {
  {
    event = { "BufEnter" },
    pattern = { "github.com_*.txt" },
    command = "set filetype=markdown",
  },
})

-- Redefine FileTypes
augroup("FileTypes AutoCmds", {
  {
    event = { "BufRead", "BufNewFile" },
    pattern = { ".eslintrc", ".prettierrc", ".babelrc" },
    command = "set filetype=json",
  },
  {
    event = { "BufRead", "BufNewFile" },
    pattern = { "*.yrl" },
    command = "set filetype=erlang",
  },
  {
    event = { "BufRead", "BufNewFile" },
    pattern = { ".envrc" },
    command = "set filetype=bash",
  },
})

-- When editing a file, always jump to the last known cursor position.
-- Don't do it for gitcommit messages
augroup("Auto Resume", {
  {
    event = { "BufReadPost" },
    pattern = { "*" },
    command = function()
      local ft = vim.bo.filetype
      local line = vim.fn.line

      local not_in_event_handler = line("'\"") > 0 and line("'\"") <= line("$")

      if not (ft == "gitcommit") and not_in_event_handler then
        vim.fn.execute('normal g`"')
      end
    end,
  },
})

augroup("General Improvements", {
  -- Vim/tmux layout rebalancing
  -- automatically rebalance windows on vim resize
  {
    event = { "VimResized" },
    pattern = { "*" },
    command = "wincmd =",
  },

  -- Automatically git commit text at 72 characters
  {
    event = { "FileType" },
    pattern = { "gitcommit" },
    command = "setlocal textwidth=72",
  },

  -- notify if file changed outside of vim to avoid multiple versions
  {
    event = { "FocusGained" },
    pattern = { "*" },
    command = "checktime",
  },

  -- Unfold all folds when opening a file
  {
    event = { "BufReadPost", "FileReadPost" },
    pattern = { "*" },
    command = "normal zR",
  },
})

augroup("LSP Stuff", {
  -- Use internal formatting for bindings like gq.
  {
    event = { "LspAttach" },
    command = function(args)
      vim.bo[args.buf].formatexpr = nil
    end,
  },
})

augroup("DebuggerBrevs", {
  {
    event = { "FileType" },
    pattern = { "ruby", "eruby" },
    command = "iabbrev <buffer> bpry require 'pry';",
  },
  {
    event = { "FileType" },
    pattern = { "elixir" },
    command = "iabbrev <buffer> ipry require IEx; IEx.pry;",
  },
})

augroup("GlobalGX", {
  {
    event = { "BufRead", "BufNewFile" },
    pattern = { "mix.exs" },
    command = function()
      vim.keymap.set("n", "gx", ":HexOpenHexDocs<CR>", { noremap = true, buffer = true, desc = "Open in HexDocs" })
    end,
  },
  {
    event = { "BufRead", "BufNewFile" },
    pattern = { "mix.exs" },
    command = function()
      vim.keymap.set("n", "gh", ":HexOpenGithub<CR>", { noremap = true, buffer = true, desc = "Open in GitHub" })
    end,
  },
})

augroup("HighlightOnYank", {
  {
    event = { "TextYankPost" },
    pattern = { "*" },
    command = function()
      vim.highlight.on_yank({ higroup = "IncSearch" })
    end,
  },
})
