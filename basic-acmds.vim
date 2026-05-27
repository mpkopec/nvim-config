fun! TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

let filePtrns2Trim = ["*.v", "*.py"]
for f in filePtrns2Trim
  execute "autocmd BufWritePre " . f . " :call TrimWhitespace()"
endfor

" Wrapping and spelling
let file_patterns_wrap = ["tex", "bib", "markdown"]
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

autocmd FileType openscad setl commentstring=//\ %s

function! ClaudeInjectFullResponse()
  let l:rfile = '/tmp/claude_last_response.md'
  if !filereadable(l:rfile) | return | endif

  let l:header_line = search('^# .*Claude.s last response', 'nw')
  let l:footer_line = search('^# .*Write your reply below', 'nw')
  if l:header_line == 0 || l:footer_line == 0 | return | endif

  let l:footer_text = getline(l:footer_line)
  let l:header_text = getline(l:header_line)
  let l:lines = readfile(l:rfile)

  execute l:header_line . ',' . l:footer_line . 'delete _'
  call append(l:header_line - 1, [l:header_text] + l:lines + [l:footer_text])

  call cursor(l:header_line + len(l:lines) + 2, 1)
endfunction

autocmd BufReadPost /tmp/claude-prompt-*.md call ClaudeInjectFullResponse()

