" Markdown code folding
let g:markdown_folding = 1

" {{{ VHDL
" VHDL formatting
let g:vhdl_indent_genportmap = 0

autocmd FileType vhdl setl comments=:--
autocmd FileType vhdl setl commentstring=--\ %s
autocmd FileType vhdl setl foldmethod=marker
" }}}

" {{{ Python
function! FormatWithBlack()
  write
  let l:out = system(expand('~') . '/.venv/bin/black --quiet ' . shellescape(expand('%')))
  if v:shell_error
    echohl ErrorMsg
    echo l:out
    echohl None
  else
    edit!
    echo 'black: OK'
  endif
endfunction

augroup python_format
  autocmd!
  autocmd FileType python nnoremap <buffer> ,pf :call FormatWithBlack()<CR>
augroup END

augroup python_folding
  autocmd!
  autocmd FileType python setlocal foldmethod=marker
augroup END
" }}}
