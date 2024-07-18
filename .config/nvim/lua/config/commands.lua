vim.cmd [[
  augroup terminal_setup | au!
  autocmd TermOpen * nnoremap <buffer><LeftRelease> <LeftRelease>i
  autocmd TermEnter * startinsert!
  augroup end
  ]]
