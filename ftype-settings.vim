" Markdown code folding
let g:markdown_folding = 1

" {{{ VHDL
function! s:VHDLHexToC() range
    let l:start = getpos("'<")
    execute a:firstline . ',' . a:lastline . 's/\%V\cx"\([0-9a-fA-F]\+\)"/0x\1/g'
    call cursor(l:start[1], l:start[2])
endfunction

function! s:CToVHDLHex() range
    let l:start = getpos("'<")
    execute a:firstline . ',' . a:lastline . 's/\%V\c0x\([0-9a-fA-F]\+\)/x"\1"/g'
    call cursor(l:start[1], l:start[2])
endfunction

function! s:VHDLIntHexToC() range
    let l:start = getpos("'<")
    execute a:firstline . ',' . a:lastline . 's/\%V\c16#\([0-9a-fA-F]\+\)#/0x\1/g'
    call cursor(l:start[1], l:start[2])
endfunction

function! s:CToVHDLIntHex() range
    let l:start = getpos("'<")
    execute a:firstline . ',' . a:lastline . 's/\%V\c0x\([0-9a-fA-F]\+\)/16#\1#/g'
    call cursor(l:start[1], l:start[2])
endfunction

" VHDL formatting
let g:vhdl_indent_genportmap = 0

augroup vhdl_settings
  autocmd!
  autocmd FileType vhdl  setl comments=:--
  autocmd FileType vhdl  setl commentstring=--\ %s
  " foldmethod is window-local: FileType fires only in the first window, so
  " new splits inherit the global default ('manual'). BufWinEnter fires for
  " every window a buffer enters and ensures the setting follows it.
  autocmd FileType vhdl  setl foldmethod=marker
  autocmd BufWinEnter *.vhd,*.vhdl setl foldmethod=marker
  autocmd FileType vhdl    vnoremap <buffer> ,xc :call <SID>VHDLHexToC()<CR>
  autocmd FileType vhdl    vnoremap <buffer> ,cx :call <SID>CToVHDLHex()<CR>
  autocmd BufWinEnter *.vhd,*.vhdl vnoremap <buffer> ,xc :call <SID>VHDLHexToC()<CR>
  autocmd BufWinEnter *.vhd,*.vhdl vnoremap <buffer> ,cx :call <SID>CToVHDLHex()<CR>
  autocmd FileType vhdl    vnoremap <buffer> ,ic :call <SID>VHDLIntHexToC()<CR>
  autocmd FileType vhdl    vnoremap <buffer> ,ci :call <SID>CToVHDLIntHex()<CR>
  autocmd BufWinEnter *.vhd,*.vhdl vnoremap <buffer> ,ic :call <SID>VHDLIntHexToC()<CR>
  autocmd BufWinEnter *.vhd,*.vhdl vnoremap <buffer> ,ci :call <SID>CToVHDLIntHex()<CR>
augroup END
" }}}

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
  autocmd FileType python setlocal foldmethod=marker
augroup END
" }}}
