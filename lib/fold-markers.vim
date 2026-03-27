" lib/fold-markers.vim - Add/remove fold markers ({{{ / }}}) around language
" constructs. Autocmds for all supported filetypes are defined at the bottom.

" ---- Helpers ----

" Build a regex matching a line that starts with any of the given keywords.
" Suitable for languages where block-starting keywords follow only whitespace
" (e.g. VHDL). For languages with optional prefixes (Python's 'async def'),
" define a pattern directly rather than using this helper.
" E.g. s:KeywordPattern(['entity', 'architecture']) -> '^\s*\(entity\|architecture\)\s'
function! s:KeywordPattern(keywords)
  return '^\s*\(' . join(a:keywords, '\|') . '\)\s'
endfunction

" Build a fold-marker comment using the buffer's commentstring setting.
" E.g. commentstring='# %s', marker='{{{' -> '# {{{'
function! s:FoldComment(marker)
  return substitute(&commentstring, '%s', a:marker, '')
endfunction

" ---- Python ----

" Matches 'class', 'def', and 'async def' (which needs priority over bare
" 'def' so it is listed first in the alternation).
let s:python_pattern = '^\s*\(async\s\+def\|class\|def\)\s'

" Return the last non-blank line of the indentation-based block starting at
" start_line. Handles multi-line signatures in two phases:
"   Phase 1 — skip the signature: if the def/class line already ends with ':'
"             it is single-line and no scan is needed; otherwise scan forward
"             for the closing ')' with optional return type annotation and ':'.
"             ':' inside type annotations always appears within parentheses, so
"             '):' at line level unambiguously terminates the signature.
"   Phase 2 — find the body end: scan forward from the signature's last line,
"             skipping blank/whitespace-only lines, stopping at the first
"             non-blank line at an equal or shallower indent level.
function! s:PythonBlockEnd(start_line)
  let start_indent = indent(a:start_line)

  " Phase 1: find the last line of the signature
  let sig_line = a:start_line
  if getline(a:start_line) !~# ':\s*\(#.*\)\?$'
    let i = a:start_line + 1
    while i <= line('$')
      if getline(i) =~# ')\s*\(->\s*.\+\)\?:\s*\(#.*\)\?$'
        let sig_line = i
        break
      endif
      let i += 1
    endwhile
  endif

  " Phase 2: find the last non-blank body line after the signature
  let end_line = sig_line
  let i        = sig_line + 1
  while i <= line('$')
    let l = getline(i)
    if empty(l) || l =~# '^\s\+$'
      let i += 1
      continue
    endif
    if indent(i) <= start_indent
      break
    endif
    let end_line = i
    let i += 1
  endwhile
  return end_line
endfunction

" Add fold markers to all unmarked class/function blocks in the buffer.
" Both the comment style (&commentstring) and fold marker tokens (&foldmarker)
" are read from buffer-local settings, so the function works correctly
" regardless of filetype or user customisation.
function! s:AddPythonFoldMarkers()
  let save_view    = winsaveview()
  let pattern      = s:python_pattern
  let markers      = split(&foldmarker, ',')
  let open_marker  = '  ' . s:FoldComment(markers[0])
  let close_marker = s:FoldComment(markers[1])

  " Collect line numbers of unmarked class/def lines
  let targets = []
  for lnum in range(1, line('$'))
    let l = getline(lnum)
    if l =~# pattern && l !~# markers[0]
      call add(targets, lnum)
    endif
  endfor

  if empty(targets)
    echo 'No unmarked classes/functions found'
    return
  endif

  " Process bottom-to-top to preserve line numbers of remaining targets
  call reverse(targets)
  for lnum in targets
    let end_line = s:PythonBlockEnd(lnum)
    let pad      = repeat(' ', indent(lnum))
    call append(end_line, pad . close_marker)
    call setline(lnum, getline(lnum) . open_marker)
  endfor

  call winrestview(save_view)
  echo printf('Added fold markers to %d block(s)', len(targets))
endfunction

" ---- Language-agnostic ----

" Remove fold markers inserted by the Add* functions above. Reads &foldmarker
" and &commentstring so it works for any filetype. Uses '@' as the regex
" delimiter to avoid clashes with comment styles that contain '/' (e.g. C,
" Verilog).
function! s:RemoveFoldMarkers()
  let save_view     = winsaveview()
  let markers       = split(&foldmarker, ',')
  let open_comment  = escape(s:FoldComment(markers[0]), '\^$.*[]~@')
  let close_comment = escape(s:FoldComment(markers[1]), '\^$.*[]~@')

  " :g@pattern@d — global delete with '@' as delimiter instead of '/'
  " to avoid breakage when the comment style contains '/' (e.g. C, Verilog)
  silent! execute 'g@^\s*' . close_comment . '\s*$@d'

  " :%s@pattern@@e — strip the opening marker from the end of class/def lines;
  " 'e' suppresses the error when no match is found
  silent! execute '%s@\s\+' . open_comment . '\s*$@@e'

  call winrestview(save_view)
  echo 'Removed fold markers'
endfunction

" ---- Mappings ----

augroup FoldMarkers
  autocmd!
  autocmd FileType python nnoremap <buffer> ,fm :call <SID>AddPythonFoldMarkers()<CR>
  autocmd FileType python nnoremap <buffer> ,fM :call <SID>RemoveFoldMarkers()<CR>
augroup END
