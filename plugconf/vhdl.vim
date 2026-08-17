" plugconf/vhdl.vim - VHDL filetype settings: hex/int literal conversion
" commands and a structural foldexpr (entity/architecture/process/... pairs,
" plus an optional marker overlay), replacing plain foldmethod=marker.

" ---- Hex/int literal conversion ----

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

" ---- VHDL formatting ----

let g:vhdl_indent_genportmap = 0

" Style flags (any subset of p=prefill, t=tabstop, a=align) used by the
" `inst:entity_name` snippet (UltiSnips/vhdl.snippets) when its trigger omits
" the `:options` suffix. An explicit suffix on the trigger itself, even an
" empty one, overrides this entirely for that expansion rather than adding to
" it. Override in your own init.vim, before or after this file is sourced.
let g:vhdl_instantiation_default_style = get(g:, 'vhdl_instantiation_default_style', 'pa')

" ---- Structural foldexpr: markers + entity/architecture/process/... pairs --

function! s:EnableVhdlExprFolds() abort
  setlocal foldmethod=expr
  setlocal foldexpr=VhdlFoldExpr(v:lnum)

  call s:BuildVhdlFoldCache()

  augroup VhdlExprFoldsBuf
    autocmd! * <buffer>
    " foldmethod=expr only re-queries foldexpr() for lines Vim thinks
    " changed, not the whole buffer, so a rebuild here can leave downstream
    " unedited lines (e.g. boilerplate 'end if;'/'end process;' lines after
    " a multi-tabstop snippet expansion) showing a stale foldlevel() until
    " something forces a full re-derive. Reassigning 'foldexpr' to itself is
    " the standard trick for that: it makes Vim recompute fold levels for
    " the whole window without discarding manually opened/closed folds, the
    " way zx/zX would.
    autocmd TextChanged,TextChangedI,InsertLeave <buffer> call s:BuildVhdlFoldCache() | let &l:foldexpr = &l:foldexpr
  augroup END
endfunction

function! VhdlFoldExpr(lnum) abort
  if !exists('b:vhdl_fold_levels') || len(b:vhdl_fold_levels) < line('$') + 1
    call s:BuildVhdlFoldCache()
  endif
  return b:vhdl_fold_levels[a:lnum]
endfunction

" Count non-overlapping occurrences of a literal substring
function! s:CountLiteral(hay, needle) abort
  if a:needle ==# '' | return 0 | endif
  let tmp = a:hay
  let c = 0
  while 1
    let p = stridx(tmp, a:needle)
    if p < 0 | break | endif
    let c += 1
    let tmp = strpart(tmp, p + strlen(a:needle))
  endwhile
  return c
endfunction

function! s:BuildVhdlFoldCache() abort
  let n = line('$')
  let b:vhdl_fold_levels = repeat([0], n + 1)  " 1..n used
  let depth = 0

  " Foldmarkers, e.g. "{{{,}}}"
  let parts = split(&l:foldmarker, ',')
  let fm_start = (len(parts) == 2 ? parts[0] : '{{{')
  let fm_end   = (len(parts) == 2 ? parts[1] : '}}}')

  for lnum in range(1, n)
    let raw = getline(lnum)

    " --- 1) Marker opens/closes: count on RAW so markers in comments work
    let opens  = s:CountLiteral(raw, fm_start)
    let closes = s:CountLiteral(raw, fm_end)

    " --- 2) Structural folding: operate on code-only text. VHDL has no
    " block-comment syntax, only '--' to end of line, so stripping is a
    " single substitution (unlike Verilog's /* */ state machine).
    let s = substitute(raw, '--.*$', '', '')

    " VHDL closes every block with the bare 'end' keyword (optionally
    " followed by a repeated construct keyword and/or label - e.g.
    " 'end process;', 'end architecture rtl;', or just 'end;'), so one word
    " covers every close, unlike Verilog's endmodule/endfunction/... set.
    let closes += len(split(s, '\C\<end\>', 1)) - 1

    " The keyword that repeats after 'end' (e.g. the 'entity' in
    " 'end entity foo;') is identical to the keyword that opened the block,
    " so scanning for openers on 's' as-is would count that same word a
    " second time as a fresh open. Strip 'end [qualifier]' phrases first so
    " only a *leading* occurrence of the keyword (the real opener) survives
    " into the scan below.
    let opens_text = substitute(s, '\C\<end\>\%(\s\+\<\%(package\s\+body\|protected\s\+body\|entity\|architecture\|process\|function\|procedure\|package\|record\|block\|component\|protected\|configuration\|loop\|if\|case\|generate\)\>\)\?', '', 'g')

    " 'entity', 'component' and 'configuration' each have a direct-
    " instantiation statement form ('label : entity lib.name;', 'label :
    " component comp_name port map (...);', 'label : configuration
    " lib.config_name;') that reuses the same keyword as the corresponding
    " *declaration* opener, but has no matching 'end' to close it -
    " counting it as an opener here would inflate depth for the rest of the
    " file. The two are distinguished by the preceding ':' (the
    " instantiation label separator), which a declaration's leading keyword
    " never has, so that colon-prefixed form is stripped before the opener
    " scan below.
    let opens_text = substitute(opens_text, '\C:\s*\zs\<\%(entity\|component\|configuration\)\>', '', 'g')

    " VHDL-2008 conditional/case-generate statements ('if cond generate' /
    " 'case sel generate') put an 'if'/'case' token on the same header line
    " as 'generate', but the whole construct is a single block closed by one
    " 'end generate;'. Counting both tokens would over-open, so when
    " 'generate' appears on a line, only it is counted as the opener and
    " 'if'/'case' are skipped for that line. 'for' and 'while' are never
    " counted as openers at all: they only ever qualify a following 'loop'
    " or 'generate', which is already counted on its own.

    " The same conditional generate can have 'elsif cond generate' and
    " 'else generate' continuation branches - still the single block opened
    " by the leading 'if'/'case ... generate' header, closed by one 'end
    " generate;'. Their branch keyword restates 'generate' on its own line
    " though, which would otherwise be miscounted as a second opener with
    " no matching close. Stripped here so only a genuine opening header's
    " 'generate' survives into the check below.
    let opens_text = substitute(opens_text, '\C\<\%(elsif\|else\)\>\zs.\{-}\<generate\>', '', 'g')

    if opens_text =~# '\C\<generate\>'
      let opens += len(split(opens_text, '\C\<generate\>', 1)) - 1
    else
      let opens += len(split(opens_text,
            \ '\C\<entity\>\|\<architecture\>\|\<process\>\|\<function\>\|\<procedure\>\|\<package\>\|\<record\>\|\<block\>\|\<component\>\|\<protected\>\|\<configuration\>\|\<loop\>\|\<if\>\|\<case\>',
            \ 1)) - 1
    endif

    " Foldlevel for this line: include opens on this line
    let level = depth + opens
    if level < 0 | let level = 0 | endif
    let b:vhdl_fold_levels[lnum] = level

    " Update depth for following lines
    let depth = depth + opens - closes
    if depth < 0 | let depth = 0 | endif
  endfor
endfunction

" ---- Structural generic/port/map/procedure-param list indentation ----

" GetVHDLindent() (vim-polyglot's bundled indent/vhdl.vim) decides whether a
" line belongs to a generic/port association list by pattern-matching the
" CURRENT line's own text (looking for a trailing ':' or '=>'). That breaks
" whenever the line doesn't have that text yet - an empty line mid-edit (a
" freshly opened line, or 'S' substitute-line), or a line whose syntax is
" momentarily invalid while still being typed. Because the script computes
" each line's indent relative to the line above it rather than from actual
" paren-nesting depth, one missed match corrupts the baseline for every
" following line, including the list's own closing ')' and the next sibling
" block.
"
" This replaces that one feature with a backward paren-depth scan of the
" real enclosing '(', mirroring how indent/python.vim locates brackets for
" continuation-line indent: derive the indent from where the opening
" 'generic ('/'port ('/'map ('/'procedure name (' line actually is, never
" from what the current or previous line's text says, so it stays correct
" regardless of in-progress or invalid syntax.
let s:vhdl_list_opener = '\c^\s*\%(generic\s\+map\|port\s\+map\|generic\|port\|map\|procedure\s\+\w\+\|function\s\+\w\+\)\s*($'

" Deliberately not searchpair()/cursor()-based: calling a cursor-moving
" search from inside indentexpr corrupts in-progress change operators
" (verified - 'S' on a single line wiped the whole buffer), since Vim
" computes the new indent while a linewise change is still pending. This
" walks getline()/comment-stripped text the same way
" s:BuildVhdlFoldCache() above already does for fold depth, so
" unmatched-'(' detection never touches the window/cursor.
function! s:VhdlFindListOpener(lnum) abort
  let depth = 1
  let lnum = a:lnum - 1
  while lnum > 0
    let s = substitute(getline(lnum), '--.*$', '', '')
    let depth -= s:CountLiteral(s, '(') - s:CountLiteral(s, ')')
    if depth <= 0
      return getline(lnum) =~ s:vhdl_list_opener ? lnum : -1
    endif
    let lnum -= 1
  endwhile
  return -1
endfunction

function! VhdlAlignedListIndent(lnum) abort
  let opener = s:VhdlFindListOpener(a:lnum)
  if opener == -1
    return GetVHDLindent()
  endif
  if getline(a:lnum) =~ '^\s*)'
    return indent(opener)
  endif
  return indent(opener) + shiftwidth()
endfunction

" ---- Autocmds ----

augroup vhdl_settings
  autocmd!
  autocmd FileType vhdl  setl comments=:--
  autocmd FileType vhdl  setl commentstring=--\ %s
  autocmd FileType vhdl  call s:EnableVhdlExprFolds()
  autocmd FileType vhdl  setlocal indentexpr=VhdlAlignedListIndent(v:lnum)
  autocmd FileType vhdl    vnoremap <buffer> ,xc :call <SID>VHDLHexToC()<CR>
  autocmd FileType vhdl    vnoremap <buffer> ,cx :call <SID>CToVHDLHex()<CR>
  autocmd BufWinEnter *.vhd,*.vhdl vnoremap <buffer> ,xc :call <SID>VHDLHexToC()<CR>
  autocmd BufWinEnter *.vhd,*.vhdl vnoremap <buffer> ,cx :call <SID>CToVHDLHex()<CR>
  autocmd FileType vhdl    vnoremap <buffer> ,ic :call <SID>VHDLIntHexToC()<CR>
  autocmd FileType vhdl    vnoremap <buffer> ,ci :call <SID>CToVHDLIntHex()<CR>
  autocmd BufWinEnter *.vhd,*.vhdl vnoremap <buffer> ,ic :call <SID>VHDLIntHexToC()<CR>
  autocmd BufWinEnter *.vhd,*.vhdl vnoremap <buffer> ,ci :call <SID>CToVHDLIntHex()<CR>
augroup END
