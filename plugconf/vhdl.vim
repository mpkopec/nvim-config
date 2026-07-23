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

    " VHDL-2008 conditional/case-generate statements ('if cond generate' /
    " 'case sel generate') put an 'if'/'case' token on the same header line
    " as 'generate', but the whole construct is a single block closed by one
    " 'end generate;'. Counting both tokens would over-open, so when
    " 'generate' appears on a line, only it is counted as the opener and
    " 'if'/'case' are skipped for that line. 'for' and 'while' are never
    " counted as openers at all: they only ever qualify a following 'loop'
    " or 'generate', which is already counted on its own.
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

" ---- Autocmds ----

augroup vhdl_settings
  autocmd!
  autocmd FileType vhdl  setl comments=:--
  autocmd FileType vhdl  setl commentstring=--\ %s
  autocmd FileType vhdl  call s:EnableVhdlExprFolds()
  autocmd FileType vhdl    vnoremap <buffer> ,xc :call <SID>VHDLHexToC()<CR>
  autocmd FileType vhdl    vnoremap <buffer> ,cx :call <SID>CToVHDLHex()<CR>
  autocmd BufWinEnter *.vhd,*.vhdl vnoremap <buffer> ,xc :call <SID>VHDLHexToC()<CR>
  autocmd BufWinEnter *.vhd,*.vhdl vnoremap <buffer> ,cx :call <SID>CToVHDLHex()<CR>
  autocmd FileType vhdl    vnoremap <buffer> ,ic :call <SID>VHDLIntHexToC()<CR>
  autocmd FileType vhdl    vnoremap <buffer> ,ci :call <SID>CToVHDLIntHex()<CR>
  autocmd BufWinEnter *.vhd,*.vhdl vnoremap <buffer> ,ic :call <SID>VHDLIntHexToC()<CR>
  autocmd BufWinEnter *.vhd,*.vhdl vnoremap <buffer> ,ci :call <SID>CToVHDLIntHex()<CR>
augroup END
