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

" Detection pattern for Python block-starting lines.
" Breakdown:
"   ^\s*                        — optional leading indentation
"   \(                          — start of the main alternation
"     async\s\+def\s\+\w\+\s*(  — async function: 'async', whitespace,
"                                  'def', whitespace, name (\w\+), optional
"                                  whitespace, opening paren (always present)
"     \|def\s\+\w\+\s*(         — regular function: same without 'async';
"                                  listed after 'async def' so the longer
"                                  alternative takes priority
"     \|class\s\+\w\+\s*[:(]    — class: name followed by either '(' (with
"                                  base classes, single- or multi-line) or
"                                  ':' (no base classes); rules out prose
"                                  uses like 'class constants, ...'
"   \)                          — end of alternation
let s:python_pattern = '^\s*\(async\s\+def\s\+\w\+\s*(\|def\s\+\w\+\s*(\|class\s\+\w\+\s*[:(]\)'

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
    let end_line  = s:PythonBlockEnd(lnum)
    let close_pad = repeat(' ', indent(lnum) + shiftwidth())
    call append(end_line, close_pad . close_marker)
    call setline(lnum, getline(lnum) . open_marker)
  endfor

  call winrestview(save_view)
  echo printf('Added fold markers to %d block(s)', len(targets))
endfunction

" Opening pattern for docstrings — matches either \"\"\" or ''' after optional
" leading whitespace. \zs marks the start of the returned portion so
" matchstr() yields the quote style directly, without a separate ternary.
let s:docstring_opener = "^\\s*\\zs\\(\"\"\"\\|'''\\)"

" Add fold markers around multi-line docstrings (\"\"\" or ''') in the buffer.
" Markers are placed on separate comment lines surrounding the docstring to
" avoid polluting the string content. Single-line docstrings are skipped.
" Scanning runs top-to-bottom so that after finding an opening triple-quote,
" we can skip past the body and avoid mistaking the closing \"\"\" for a new
" opening.
function! s:AddPythonDocstringFoldMarkers()
  let save_view    = winsaveview()
  let markers      = split(&foldmarker, ',')
  let open_marker  = s:FoldComment(markers[0])
  let close_marker = s:FoldComment(markers[1])

  " Collect [open_lnum, close_lnum] pairs for unmarked multi-line docstrings
  let targets = []
  let lnum = 1
  while lnum <= line('$')
    let l     = getline(lnum)
    let quote = matchstr(l, s:docstring_opener)
    if !empty(quote)
      " Skip single-line docstrings: opening and closing on same line.
      " .\{-} is vim's non-greedy .* — matches the content between the quotes.
      if l =~# '^\s*' . quote . '.\{-}' . quote . '\s*$'
        let lnum += 1
        continue
      endif

      " Multi-line: scan forward for the closing triple-quote
      let close_lnum = -1
      let i = lnum + 1
      while i <= line('$')
        if getline(i) =~# quote . '\s*\(#.*\)\?$'
          let close_lnum = i
          break
        endif
        let i += 1
      endwhile

      " Add to targets if closing was found and not already marked.
      " Check the line above the opener (where # {{{ will be inserted) and
      " the opener itself in case the user placed a marker there manually.
      if close_lnum != -1 && getline(lnum - 1) !~# markers[0] && l !~# markers[0]
        call add(targets, [lnum, close_lnum])
      endif

      " Skip past the docstring body so the closing \"\"\" is not mistaken
      " for a new opening on the next iteration
      let lnum = (close_lnum != -1 ? close_lnum : lnum) + 1
      continue
    endif
    let lnum += 1
  endwhile

  if empty(targets)
    echo 'No unmarked multi-line docstrings found'
    return
  endif

  " Process bottom-to-top to preserve line numbers of remaining targets.
  " Within each pair, insert the closing marker first so the opener insertion
  " does not shift close_lnum before we use it.
  call reverse(targets)
  for [open_lnum, close_lnum] in targets
    let pad = repeat(' ', indent(open_lnum))
    call append(close_lnum, pad . close_marker)
    call append(open_lnum - 1, pad . open_marker)
  endfor

  call winrestview(save_view)
  echo printf('Added fold markers to %d docstring(s)', len(targets))
endfunction

" Run all Python fold marker functions in sequence. Bound to ,fm so a single
" mapping handles both class/function blocks and docstrings in one pass.
function! s:AddAllPythonFoldMarkers()
  call s:AddPythonFoldMarkers()
  call s:AddPythonDocstringFoldMarkers()
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
  autocmd FileType python nnoremap <buffer> ,fm :call <SID>AddAllPythonFoldMarkers()<CR>
  autocmd FileType python nnoremap <buffer> ,fM :call <SID>RemoveFoldMarkers()<CR>
augroup END
