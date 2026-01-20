" let b:verilog_indent_width = 2
" let g:verilog_disable_indent_lst = "eos"

" let g:verilog_syntax_fold_lst = "function,task,specify,interface,clocking,covergroup,sequence,property,block_nested"
let g:verilog_syntax_fold_lst = "all"

autocmd BufEnter *.v set filetype=verilog_systemverilog
autocmd BufEnter *.v set shiftwidth=2
autocmd BufEnter *.sv set filetype=verilog_systemverilog
autocmd BufEnter *.sv set shiftwidth=2

autocmd FileType verilog_systemverilog nnoremap <buffer> ,fi :VerilogFollowInstance<cr>
autocmd FileType verilog_systemverilog nnoremap <buffer> ,fp :VerilogFollowPort<cr>

autocmd FileType verilog_systemverilog setl commentstring=//\ %s

" --- SystemVerilog foldexpr: markers + structural pairs ----------------------

augroup SvExprFolds
  autocmd!
  autocmd FileType verilog,systemverilog,verilog_systemverilog call s:EnableSvExprFolds()
augroup END

function! s:EnableSvExprFolds() abort
  setlocal foldmethod=expr
  setlocal foldexpr=SvFoldExpr(v:lnum)
  " optional default view
  " setlocal foldlevel=1

  call s:BuildSvFoldCache()

  augroup SvExprFoldsBuf
    autocmd! * <buffer>
    autocmd TextChanged,TextChangedI,InsertLeave <buffer> call s:BuildSvFoldCache()
  augroup END
endfunction

function! SvFoldExpr(lnum) abort
  if !exists('b:sv_fold_levels') || len(b:sv_fold_levels) < line('$') + 1
    call s:BuildSvFoldCache()
  endif
  return b:sv_fold_levels[a:lnum]
endfunction

function! s:BuildSvFoldCache() abort
  let n = line('$')
  let b:sv_fold_levels = repeat([0], n + 1)  " 1..n used
  let depth = 0
  let inblock = 0

  " Foldmarkers, e.g. "{{{,}}}"
  let parts = split(&l:foldmarker, ',')
  let fm_start = (len(parts) == 2 ? parts[0] : '{{{')
  let fm_end   = (len(parts) == 2 ? parts[1] : '}}}')

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

  for lnum in range(1, n)
    let raw = getline(lnum)

    " --- 1) Marker opens/closes: count on RAW so markers in comments work
    let opens  = s:CountLiteral(raw, fm_start)
    let closes = s:CountLiteral(raw, fm_end)

    " --- 2) Structural folding: operate on code-only text (strip comments)
    let s = raw

    " Strip block comments /* ... */ (simple state machine)
    if inblock
      let p = match(s, '\*/')
      if p < 0
        let s = ''
      else
        let s = strpart(s, p + 2)
        let inblock = 0
      endif
    endif

    while !inblock
      let p1 = match(s, '/\*')
      if p1 < 0 | break | endif
      let p2 = match(s, '\*/', p1 + 2)
      if p2 < 0
        let s = strpart(s, 0, p1)
        let inblock = 1
        break
      else
        let s = strpart(s, 0, p1) . strpart(s, p2 + 2)
      endif
    endwhile

    " Strip line comments //...
    let s = substitute(s, '//.*$', '', '')

    " Structural opens
    let opens += len(split(s,
          \ '\C\<module\>\|\<package\>\|\<class\>\|\<function\>\|\<task\>\|\<begin\>\|\<case\>\|\<casex\>\|\<casez\>\|\<generate\>\|\<fork\>\|\<covergroup\>\|\<clocking\>\|\<interface\>\|\<program\>',
          \ 1)) - 1

    " Structural closes
    let closes += len(split(s,
          \ '\C\<endmodule\>\|\<endpackage\>\|\<endclass\>\|\<endfunction\>\|\<endtask\>\|\<end\>\|\<endcase\>\|\<endgenerate\>\|\<join\>\|\<join_any\>\|\<join_none\>\|\<endgroup\>\|\<endclocking\>\|\<endinterface\>\|\<endprogram\>',
          \ 1)) - 1

    " Preprocessor conditionals
    let opens  += len(split(s, '\C`ifdef\>\|`ifndef\>', 1)) - 1
    let closes += len(split(s, '\C`endif\>',           1)) - 1

    " `else / `elsif => close one branch, open another (same depth)
    let branch = (len(split(s, '\C`else\>\|`elsif\>', 1)) - 1)
    let opens  += branch
    let closes += branch

    " Foldlevel for this line: include opens on this line
    let level = depth + opens
    if level < 0 | let level = 0 | endif
    let b:sv_fold_levels[lnum] = level

    " Update depth for following lines
    let depth = depth + opens - closes
    if depth < 0 | let depth = 0 | endif
  endfor
endfunction

" For instantiation in the future
" For automatic parameter assignment to declaration:
" '<,'>s/\.\(\w\+\)(\(\("\w\+"\)\|\d[.0-9]*\))/parameter \1 = \2/
