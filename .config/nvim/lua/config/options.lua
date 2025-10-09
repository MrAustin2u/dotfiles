----------------------------------------------
-- Cache and directories
----------------------------------------------
local cache_dir = string.format("%s/.cache/nvim/", vim.env.HOME)

----------------------------------------------
-- Leader keys
----------------------------------------------
vim.g.mapleader = " "      -- Space as leader key
vim.g.maplocalleader = " " -- Space as local leader key

----------------------------------------------
-- Global settings
----------------------------------------------
vim.g.autoformat = true             -- Enable autoformatting
vim.g.loaded_netrw = 1              -- Disable netrw
vim.g.loaded_netrwPlugin = 1        -- Disable netrw plugin
vim.g.markdown_fenced_languages = { -- Syntax highlighting for markdown code blocks
  "shell=sh",
  "bash=sh",
  "zsh=sh",
  "console=sh",
  "vim",
  "lua",
  "cpp",
  "sql",
  "elixir",
  "python",
  "javascript",
  "typescript",
  "js=javascript",
  "ts=typescript",
  "yaml",
  "json",
}

----------------------------------------------
-- Appearance and UI
----------------------------------------------
vim.cmd.syntax "off" -- Disable syntax highlighting (using treesitter)
vim.opt.bg = "dark" -- Dark background
vim.opt.ch = 0 -- Command line height
vim.opt.cmdheight = 1 -- Command line height
vim.opt.colorcolumn = "120" -- Show column at 120 characters
vim.opt.cursorline = true -- Highlight current line
vim.opt.fillchars = "fold: ,vert:│,eob: ,msgsep:‾" -- Characters for UI elements
vim.opt.guifont = "MonoLisa:h14" -- GUI font
vim.opt.laststatus = 3 -- Global statusline
vim.opt.list = true -- Show invisible characters
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" } -- Characters for invisible chars
vim.opt.number = true -- Show line numbers
vim.opt.pumblend = 20 -- Popup menu transparency
vim.opt.pumheight = 10 -- Popup menu height
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.showcmd = true -- Show command in status line
vim.opt.showmatch = true -- Show matching brackets
vim.opt.signcolumn = "yes" -- Always show sign column
vim.opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]] -- Custom status column
vim.opt.termguicolors = true -- Enable 24-bit RGB colors
vim.opt.winborder = "rounded" -- Rounded window borders

----------------------------------------------
-- Scrolling and navigation
----------------------------------------------
vim.opt.scrolloff = 8        -- Keep 8 lines above/below cursor
vim.opt.sidescrolloff = 8    -- Keep 8 columns left/right of cursor
vim.opt.smoothscroll = true  -- Smooth scrolling
vim.opt.splitkeep = "screen" -- Keep splits on screen
vim.opt.splitright = true    -- Open splits to the right
vim.opt.ttyfast = true       -- Fast terminal connection
vim.opt.wrap = true          -- Wrap long lines

----------------------------------------------
-- Search and matching
----------------------------------------------
vim.opt.hlsearch = false -- Don't highlight search results
vim.opt.matchtime = 1    -- Time to show matching bracket

----------------------------------------------
-- Editing behavior
----------------------------------------------
vim.opt.autowrite = true                                  -- Auto-save before running commands
vim.opt.hidden = true                                     -- Allow hidden buffers
vim.opt.mouse = "a"                                       -- Enable mouse support
vim.opt.shortmess:append { W = true, I = true, c = true } -- Reduce messages

----------------------------------------------
-- Timing
----------------------------------------------
vim.opt.timeout = true   -- Enable timeouts
vim.opt.timeoutlen = 300 -- Mapping timeout
vim.opt.ttimeoutlen = 0  -- Key code timeout
vim.opt.updatetime = 50  -- Faster completion

----------------------------------------------
-- Folding
----------------------------------------------
vim.opt.foldenable = false                                     -- Disable folding by default
vim.opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()" -- Fold expression
vim.opt.foldmethod = "expr"                                    -- Use expression for folding
vim.opt.foldtext = ""                                          -- Empty fold text

----------------------------------------------
-- Formatting
----------------------------------------------
vim.opt.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()" -- Format expression
vim.opt.formatoptions:append "r"                                       -- Auto-insert comment leader

----------------------------------------------
-- Completion
----------------------------------------------
vim.opt.complete:append "kspell"                        -- Include spell checking in completion
vim.opt.completeopt = { "menu", "menuone", "noselect" } -- Completion options

----------------------------------------------
-- Indentation and tabs
----------------------------------------------
local indent = 2
vim.opt.expandtab = true     -- Use spaces instead of tabs
vim.opt.shiftround = true    -- Round indent to multiple of shiftwidth
vim.opt.shiftwidth = indent  -- Number of spaces for auto-indent
vim.opt.smartindent = false  -- Disable smart indent (conflicts with # comments)
vim.opt.softtabstop = indent -- Number of spaces for tab in insert mode
vim.opt.tabstop = indent     -- Number of spaces for tab character

----------------------------------------------
-- Files and backup
----------------------------------------------
vim.opt.backup = false                     -- Disable backup files
vim.opt.backupdir = cache_dir .. "backup/" -- Backup directory
vim.opt.swapfile = false                   -- Disable swap files
vim.opt.undofile = true                    -- Enable persistent undo

----------------------------------------------
-- Spell checking
----------------------------------------------
vim.opt.spelllang = "en"                              -- English spell checking
vim.opt.spellfile = cache_dir .. "spell/en.utf-8.add" -- Custom spell file
vim.opt_global.spell = true                           -- Enable spell checking globally

----------------------------------------------
-- Diff options
----------------------------------------------
vim.opt.diffopt:append "vertical"           -- Use vertical diffs
vim.opt.diffopt:append "filler"             -- Show filler lines
vim.opt.diffopt:append "iwhite"             -- Ignore whitespace
vim.opt.diffopt:append "algorithm:patience" -- Use patience diff algorithm
vim.opt.diffopt:append "indent-heuristic"   -- Use indent heuristic

----------------------------------------------
-- File handling
----------------------------------------------
vim.opt.wildoptions = "pum" -- Use popup menu for file completion

-- Persistent undo configuration
if vim.fn.has "persistent_undo" then
  vim.opt.undofile = true                -- Enable persistent undo
  vim.opt.undodir = cache_dir .. "undo/" -- Undo directory
end

-- RipGrep integration
if vim.fn.executable "rg" then
  vim.opt.grepprg = "rg --vimgrep --no-heading" -- Use ripgrep for grep
  vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"   -- Grep output format
end

----------------------------------------------
-- LSP and diagnostics
----------------------------------------------
vim.lsp.set_log_level "off" -- Disable LSP logging
