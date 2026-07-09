function! ToggleFullZoom()
  if exists('t:is_zoom_tab') && t:is_zoom_tab
    tabclose
  else
    tab split
    let t:is_zoom_tab = 1
  endif
endfunction

" winrestcmd() captures a string of :resize/:vertical resize commands that
" restore every window's dimensions in the current tab — stored per-window
" so two windows in the same tab can each track their own pre-zoom state.
function! ToggleColumnZoom()
  if exists('w:col_zoomed') && w:col_zoomed
    execute w:col_restore
    unlet w:col_zoomed w:col_restore
  else
    let w:col_restore = winrestcmd()
    wincmd _
    let w:col_zoomed = 1
  endif
endfunction

nnoremap ,wf :call ToggleFullZoom()<CR>
nnoremap ,wc :call ToggleColumnZoom()<CR>
