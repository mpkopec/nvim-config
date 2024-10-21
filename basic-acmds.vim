fun! TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

let filePtrns2Trim = ["*.v", "*.py"]
for f in filePtrns2Trim
  execute "autocmd BufWritePre " . f . " :call TrimWhitespace()"
endfor

let file_patterns_wrap = ["tex", "bib"]
for f in file_patterns_wrap
  execute "autocmd FileType " . f . " setlocal wrap"
  execute "autocmd FileType " . f . " setlocal spell"
endfor

autocmd FileType python set shiftwidth=4
autocmd FileType python set tabstop=4
autocmd FileType python set sts=4
autocmd FileType python set expandtab

" Indentation guides
set list
" Update the guides after every change to the shiftwidth option
autocmd OptionSet shiftwidth execute 'setlocal listchars=trail:·,tab:│\ ,leadmultispace:┆' . repeat('\ ', &sw - 1)
" Start the guides after loading the buffer as well
autocmd BufWinEnter * execute 'setlocal listchars=trail:·,tab:│\ ,leadmultispace:┆' . repeat('\ ', &sw - 1)

autocmd BufReadPost *.tex execute "setlocal nolist"
autocmd BufReadPost *.bib execute "setlocal nolist"
