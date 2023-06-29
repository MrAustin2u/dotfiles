local cmd, g, fn, o, opt = vim.cmd, vim.g, vim.fn, vim.o, vim.opt
local tmpdir = string.format("%s/.vim/tmp, ", vim.env.HOME)

-- support syntax highlighting
cmd("syntax enable")
-- try to recognize filetypes and load rel' plugins
cmd("filetype plugin indent on")

g.mapleader = " "
g.maplocalleader = " "
g.matchup_surround_enabled = true
g.matchup_matchparen_deferred = true
g.matchup_matchparen_offscreen = {
  method = "popup",
  fullwidth = true,
  highlight = "Normal",
  border = "shadow",
}
g.markdown_fenced_languages = {
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
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

o.background = "dark"
o.laststatus = 2 -- Always display the status line
o.mouse = "a"
o.termguicolors = true

opt.autowrite = true -- Enable auto write
opt.backspace = "indent,eol,start" -- Backspace deletes like most programs in insert mode
opt.backup = false
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.cmdheight = 2
opt.colorcolumn = "120"
opt.compatible = false
opt.complete:append("kspell") -- Autocomplete with dictionary words when spell check is on
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 3 -- Hide * markup for bold and italic
opt.confirm = true -- Confirm to save changes before exiting modified buffer
-----------------------------------------------------------------------------//
-- Cursor {{{1
-----------------------------------------------------------------------------//
opt.cursorline = true -- Enable highlighting of the current line
opt.cursorlineopt = "number" -- optionally -> "screenline,number"
-----------------------------------------------------------------------------//
opt.emoji = false
opt.encoding = "utf-8"
opt.errorbells = false
opt.expandtab = true -- Use spaces instead of tabs
opt.guifont = "MonoLisa Nerd Font:h15"
opt.fillchars = { eob = "~" }
opt.hidden = true
opt.hlsearch = false
opt.ignorecase = true -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.incsearch = true
opt.list = true -- Show some invisible characters (tabs...
opt.listchars = {
  eol = nil,
  extends = "›", -- Alternatives: … »
  nbsp = "+",
  precedes = "‹", -- Alternatives: … «
  tab = "│ ",
  trail = "•", -- BULLET (U+2022, UTF-8: E2 80 A2)
}
opt.mouse = "nva" -- Enable mouse mode
opt.mousefocus = true
opt.number = true -- Print line number
opt.pumblend = 20
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.redrawtime = 5000 -- prevent vim from disabling highlighting if the code is complex
opt.relativenumber = false -- Relative line numbers
opt.ruler = true
opt.scrolloff = 4 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
opt.shell = "/opt/homebrew/bin/zsh" -- Use zsh as the default shell
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true })
opt.showmatch = true
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.softtabstop = 2
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.swapfile = false
opt.tabstop = 2 -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.timeoutlen = 300
opt.ttimeoutlen = 10
opt.ttyfast = true -- should make scrolling faster
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 50 -- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
opt.viewoptions:remove("options")
opt.visualbell = true
opt.wildmenu = true
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.wildoptions = "pum"
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap
-----------------------------------------------------------------------------//
-- Utilities {{{1
-----------------------------------------------------------------------------//
vim.o.showmode = false -- show current mode (insert, etc) under the cmdline
vim.o.showcmd = true -- show current mode (insert, etc) under the cmdline
-- NOTE: Don't remember
-- * help files since that will error if they are from a lazy loaded plugin
-- * folds since they are created dynamically and might be missing on startup
vim.opt.sessionoptions = {
  "blank",
  "buffers",
  "curdir",
  "folds",
  "globals",
  -- "help",
  -- "tabpages",
  "terminal",
  "winpos",
  "winsize",
}
vim.opt.viewoptions = { "cursor", "folds" } -- save/restore just these (with `:{mk,load}view`)
vim.o.virtualedit = "block" -- allow cursor to move where there is no text in visual block mode
-----------------------------------------------------------------------------//

-------------------------------------------------------------------------------
-- BACKUP AND SWAPS {{{
-------------------------------------------------------------------------------
-- set where swap file and undo/backup files are saved
opt.backupdir = tmpdir
opt.directory = tmpdir

-- persistent undo between file reloads
if vim.fn.has("persistent_undo") then
  opt.undofile = true
  opt.undodir = tmpdir
end
-----------------------------------------------------------------------------//
-- Spelling {{{1
-----------------------------------------------------------------------------//
opt.spellsuggest:prepend({ 12 })
opt.spelloptions:append({ "camel", "noplainbuffer" })
o.spellcapcheck = "" -- don't check for capital letters at start of sentence
o.dictionary = "/usr/share/dict/words"

o.spellfile = fn.expand("$DOTS/config/nvim/spell/en.utf-8.add")
o.spelllang = "en"
opt.fileformats = { "unix", "mac", "dos" }
-----------------------------------------------------------------------------//
-- ShaDa (viminfo for vim): session data history
-----------------------------------------------------------------------------//
--Defer loading shada until after startup_
local shadafile = opt.shadafile
opt.shadafile = "NONE"
-----------------------------------------------------------------------------//

vim.schedule(function()
  opt.shadafile = shadafile
  cmd([[ silent! rsh ]])
end)

-- Use RipGrep for grep https://www.wezm.net/technical/2016/09/ripgrep-with-vim/
if fn.executable("rg") then
  opt.grepprg = "rg --vimgrep --no-heading"
  opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end
