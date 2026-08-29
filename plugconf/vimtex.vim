let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'
" Do not focus the PDF viewer automatically, or rather do not issue opening the
" viewer command each time the compilation is done. Good viewers refresh
" themselves.
let g:vimtex_view_automatic = 0

let g:vimtex_format_enabled = 0

" Setup YCM for latex
if !exists('g:ycm_semantic_triggers')
  let g:ycm_semantic_triggers = {}
endif
au VimEnter * let g:ycm_semantic_triggers.tex=g:vimtex#re#youcompleteme

let maplocalleader = ""

" Remap the standard commands to , + something, but do not set the comma as
" the localleader to still preserve its function of reverse search in line
autocmd FileType tex nnoremap ,li <plug>(vimtex-info)
autocmd FileType tex nnoremap ,lI <plug>(vimtex-info-full)
autocmd FileType tex nnoremap ,lt <plug>(vimtex-toc-open)
autocmd FileType tex nnoremap ,lT <plug>(vimtex-toc-toggle)
autocmd FileType tex nnoremap ,lq <plug>(vimtex-log)
autocmd FileType tex nnoremap ,lv <plug>(vimtex-view)
autocmd FileType tex nnoremap ,lr <plug>(vimtex-reverse-search)
autocmd FileType tex nnoremap ,ll <plug>(vimtex-compile)
autocmd FileType tex nnoremap ,lL <plug>(vimtex-compile-selected)
autocmd FileType tex xnoremap ,lL <plug>(vimtex-compile-selected)
autocmd FileType tex nnoremap ,lk <plug>(vimtex-stop)
autocmd FileType tex nnoremap ,lK <plug>(vimtex-stop-all)
autocmd FileType tex nnoremap ,le <plug>(vimtex-errors)
autocmd FileType tex nnoremap ,lo <plug>(vimtex-compile-output)
autocmd FileType tex nnoremap ,lg <plug>(vimtex-status)
autocmd FileType tex nnoremap ,lG <plug>(vimtex-status-all)
autocmd FileType tex nnoremap ,lc <plug>(vimtex-clean)
autocmd FileType tex nnoremap ,lC <plug>(vimtex-clean-full)
autocmd FileType tex nnoremap ,lx <plug>(vimtex-reload)
autocmd FileType tex nnoremap ,lX <plug>(vimtex-reload-state)
autocmd FileType tex nnoremap ,la <plug>(vimtex-context-menu)

" TikZ scratchpad workflow: ,ls previews the current figure fragment
" standalone against <root>/scratchpad.tex (fast, no full-thesis recompile);
" ,lm switches back to the project's main.tex. Relies on the .latexmain
" marker convention to find the project root, and on a scratchpad.tex
" existing there (see phd_thesis repo). Overrides the former ,ls
" (vimtex-toggle-main, inert outside the LaTeX subfiles package) and ,lm
" (vimtex-imaps-list, unused) bindings.
function! s:VimtexScratchRoot() abort
  let l:dir = expand('%:p:h')
  while l:dir !=# '/' && !filereadable(l:dir . '/main.tex.latexmain')
    let l:dir = fnamemodify(l:dir, ':h')
  endwhile
  return filereadable(l:dir . '/main.tex.latexmain') ? l:dir : ''
endfunction

function! s:VimtexScratchEnter() abort
  let l:root = s:VimtexScratchRoot()
  if empty(l:root) || !filereadable(l:root . '/scratchpad.tex')
    echohl WarningMsg | echom 'vimtex scratchpad: no scratchpad.tex found from this buffer' | echohl None
    return
  endif
  let l:figure = expand('%:p')
  let l:rel = substitute(l:figure, '^' . escape(l:root, '/\') . '/', '', '')
  " Guard: only figure fragments under Figures/tikz/ make sense as a scratch
  " target. Without this, running ,ls from main.tex itself would redirect
  " _scratch.tex to \input{main.tex} -- scratchpad.tex would then embed the
  " whole thesis inside a preamble that already defines every one of its
  " macros/glossary entries, producing a wall of "already defined" errors.
  if l:rel !~# '^Figures/tikz/' || l:rel ==# 'Figures/tikz/_scratch.tex'
    echohl WarningMsg
    echom 'vimtex scratchpad: ,ls only makes sense from a Figures/tikz/*.tex figure file, not ' . l:rel
    echohl None
    return
  endif
  call writefile(['\input{' . l:rel . '}'], l:root . '/Figures/tikz/_scratch.tex')
  let b:vimtex_main = l:root . '/scratchpad.tex'
  VimtexReloadState
  VimtexCompile
  echom 'vimtex main -> scratchpad.tex (' . l:rel . ')'
endfunction

function! s:VimtexScratchLeave() abort
  if exists('b:vimtex_main')
    silent! VimtexStop
    unlet b:vimtex_main
    VimtexReloadState
    echom 'vimtex main -> main.tex'
  endif
endfunction

autocmd FileType tex nnoremap ,ls :call <SID>VimtexScratchEnter()<cr>
autocmd FileType tex nnoremap ,lm :call <SID>VimtexScratchLeave()<cr>
