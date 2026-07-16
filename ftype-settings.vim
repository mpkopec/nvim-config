" Markdown code folding
let g:markdown_folding = 1

" VHDL settings moved to plugconf/vhdl.vim (hex/int conversion, folding,
" instantiation-snippet style flag).

" {{{ XDC
augroup xdc_settings
  autocmd!
  autocmd BufRead,BufNewFile *.xdc setl filetype=xdc
  autocmd FileType xdc setl commentstring=#\ %s
  autocmd FileType xdc setl foldmethod=marker
  autocmd BufWinEnter *.xdc setl foldmethod=marker
augroup END
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
  " indent, not marker: Python's default foldmarker ({{{/}}}) collides with
  " literal triple-brace text that legitimately occurs in f-strings and
  " Jinja2 templates (e.g. f"{{{n}"), producing runaway folds. The prior
  " marker-based approach (lib/fold-markers.vim, ,fm/,fM) is preserved at
  " git tag python-fold-markers-pre-removal.
  autocmd FileType python setlocal foldmethod=indent
augroup END
" }}}
