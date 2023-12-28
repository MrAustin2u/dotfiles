local cache_dir = string.format("%s/.cache/nvim/", vim.env.HOME)

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.matchup_surround_enabled = true
vim.g.matchup_matchparen_deferred = true
vim.g.matchup_matchparen_offscreen = {
  method = "popup",
  fullwidth = true,
  highlight = "Normal",
  border = "shadow",
}
vim.g.markdown_fenced_languages = {
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
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.cmd.syntax("off")
vim.opt.backupdir = cache_dir .. "backup/"
vim.opt.bg = "dark"
vim.opt.ch = 0
-- vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 1
vim.opt.colorcolumn = "120"
vim.opt.completeopt = "menu,menuone,noselect"

-- Make diffing better
-- https://vimways.org/2018/the-power-of-diff/
----------------------------------------------
-- Always use vertical diffs
vim.opt.diffopt:append("vertical")
vim.opt.diffopt:append("filler")
-- ignore whitespace
vim.opt.diffopt:append("iwhite")
vim.opt.diffopt:append("algorithm:patience")
vim.opt.diffopt:append("indent-heuristic")
----------------------------------------------
vim.opt.autowrite = true -- Automatically :write before running commands
vim.opt.ch = 0           -- Command line height
vim.opt.expandtab = true
vim.opt.fillchars = "fold: ,vert:│,eob: ,msgsep:‾"
vim.opt.foldenable = false
vim.opt.guifont = "MonoLisa:h15"
vim.opt.hidden = true
vim.opt.hlsearch = false
vim.opt.laststatus = 3
vim.opt.matchtime = 1
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.pumblend = 20
vim.opt.pumheight = 10
vim.opt.scrolloff = 8
vim.opt.shiftwidth = 2
vim.opt.showcmd = true
vim.opt.showmatch = true
vim.opt.shortmess:append({ W = true, I = true, c = true })
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.smartindent = false
vim.opt.softtabstop = 2
vim.opt.spelllang = "en"
vim.opt.splitright = true
vim.opt.splitkeep = "screen"
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 0
vim.opt.undofile = true
vim.opt.updatetime = 50
vim.opt.wrap = true
----------------------------------------------
-- Files and directories
----------------------------------------------
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.spellfile = cache_dir .. "spell/en.uft-8.add"
vim.opt_global.spell = true

-- persistent undo between file reloads
if vim.fn.has("persistent_undo") then
  vim.opt.undofile = true
  vim.opt.undodir = cache_dir .. "undo/"
end
