local opt, cmd, o, wo, g, fn = vim.opt, vim.cmd, vim.o, vim.wo, vim.g, vim.fn

-- globals
g.matchup_surround_enabled = true
g.matchup_matchparen_deferred = true
g.matchup_matchparen_offscreen = {
  method = "popup",
  fullwidth = true,
  highlight = "Normal",
  border = "shadow",
}
-- disable the default highlight group
g.conflict_marker_highlight_group = "Error"
-- Include text after begin and end markers
g.conflict_marker_begin = "^<<<<<<< .*$"
g.conflict_marker_end = "^>>>>>>> .*$"
g.markdown_fenced_languages = {
  "shell=sh",
  "bash=sh",
  "zsh=sh",
  "console=sh",
  "vim",
  "lua",
  "sql",
  "elixir",
  "javascript",
  "typescript",
  "js=javascript",
  "ts=typescript",
  "yaml",
  "json",
}

-- opts
o.termguicolors = true
o.mouse = "nva"
o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
wo.wrap = false
opt.shell = "/opt/homebrew/bin/zsh" -- Use zsh as the default shell
opt.autoindent = true
opt.backup = false
opt.cmdheight = 2
opt.compatible = false
opt.completeopt = { "menu", "menuone", "noselect", "noinsert" }
opt.confirm = true
opt.cursorline = true
opt.cursorlineopt = "both" -- optionally -> "screenline,number"
opt.emoji = false
opt.encoding = "utf-8"
opt.errorbells = false
opt.expandtab = true
opt.hlsearch = false
opt.ignorecase = true
opt.incsearch = true
opt.lazyredraw = true
opt.mousefocus = true
opt.number = true
opt.ruler = true
opt.shell = "zsh"
opt.showmode = false
opt.shiftwidth = 2
opt.signcolumn = "yes"
opt.shortmess = "atToOFc"
opt.smartcase = true
opt.smartindent = true
opt.softtabstop = 2
opt.swapfile = false
opt.tabstop = 2
opt.updatetime = 300
opt.timeout = true
opt.timeoutlen = 500
opt.ttimeoutlen = 10
opt.visualbell = true
opt.wildmenu = true
opt.wildmode = { "list", "longest", "full" }
opt.writebackup = false
opt.backup = false
opt.writebackup = false
if fn.isdirectory(o.undodir) == 0 then
  fn.mkdir(o.undodir, "p")
end
opt.undofile = true
opt.swapfile = false
-- The // at the end tells Vim to use the absolute path to the file to create the swap file.
-- This will ensure that swap file name is unique, so there are no collisions between files
-- with the same name from different directories.
opt.directory = fn.stdpath("data") .. "/swap//"
if fn.isdirectory(vim.o.directory) == 0 then
  fn.mkdir(vim.o.directory, "p")
end

cmd([[syntax on]])
cmd([[filetype plugin indent on]])
cmd([[highlight LineNr ctermbg=NONE guibg=NONE]])
cmd([[highlight NonText ctermfg=19 guifg=#333333]])
cmd([[autocmd StdinReadPre * let s:std_in=1]])
cmd([[autocmd TextYankPost * silent! lua vim.highlight.on_yank({ higroup = "IncSearch", timeout = 500 })]])
