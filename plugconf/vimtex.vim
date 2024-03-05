let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'

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
autocmd FileType tex nnoremap ,lm <plug>(vimtex-imaps-list)
autocmd FileType tex nnoremap ,lx <plug>(vimtex-reload)
autocmd FileType tex nnoremap ,lX <plug>(vimtex-reload-state)
autocmd FileType tex nnoremap ,ls <plug>(vimtex-toggle-main)
autocmd FileType tex nnoremap ,la <plug>(vimtex-context-menu)
