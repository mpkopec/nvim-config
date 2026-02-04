" --- WSL clipboard bridge for writes to the + register ------------------------

if exists('g:loaded_wsl_plus_clip') | finish | endif
let g:loaded_wsl_plus_clip = 1

function! s:IsWSL() abort
  " Most reliable: Microsoft/WSL appears in kernel release
  if filereadable('/proc/sys/kernel/osrelease')
    let l:rel = join(readfile('/proc/sys/kernel/osrelease'), "\n")
    return l:rel =~? 'microsoft' || l:rel =~? 'wsl'
  endif
  " Fallback: WSLENV is commonly set
  return exists('$WSLENV')
endfunction

function! s:WSLClipFromPlus() abort
  " Avoid recursion if something indirectly touches registers
  if exists('s:_busy') && s:_busy | return | endif
  let s:_busy = 1
  try
    " getreg('+') returns the text; preserve newlines exactly
    let l:txt = getreg('+', 1, 1)          " (reg, 1=raw, 1=list)
    let l:payload = join(l:txt, "\n")
    " Use stdin to avoid shell quoting issues
    call system('wsl-clip', l:payload)
  finally
    let s:_busy = 0
  endtry
endfunction

if s:IsWSL() && executable('wsl-clip')
  augroup WslPlusToWindowsClipboard
    autocmd!
    " Fires whenever any y/d/c/... updates a register; filter only '+'
    autocmd TextYankPost * if v:event.regname ==# '+' | call s:WSLClipFromPlus() | endif
  augroup END
endif

