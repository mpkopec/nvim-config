let g:vimtex_view_general_viewer = 'okular'
let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'

let maplocalleader = ""

" Remap the standard commands to , + something, but do not set the comma as
" the localleader to still preserve its function of reverse search in line
autocmd FileType latex nnoremap ,li <plug>(vimtex-info)
autocmd FileType latex nnoremap ,lI <plug>(vimtex-info-full)
autocmd FileType latex nnoremap ,lt <plug>(vimtex-toc-open)
autocmd FileType latex nnoremap ,lT <plug>(vimtex-toc-toggle)
autocmd FileType latex nnoremap ,lq <plug>(vimtex-log)
autocmd FileType latex nnoremap ,lv <plug>(vimtex-view)
autocmd FileType latex nnoremap ,lr <plug>(vimtex-reverse-search)
autocmd FileType latex nnoremap ,ll <plug>(vimtex-compile)
autocmd FileType latex nnoremap ,lL <plug>(vimtex-compile-selected)
autocmd FileType latex xnoremap ,lL <plug>(vimtex-compile-selected)
autocmd FileType latex nnoremap ,lk <plug>(vimtex-stop)
autocmd FileType latex nnoremap ,lK <plug>(vimtex-stop-all)
autocmd FileType latex nnoremap ,le <plug>(vimtex-errors)
autocmd FileType latex nnoremap ,lo <plug>(vimtex-compile-output)
autocmd FileType latex nnoremap ,lg <plug>(vimtex-status)
autocmd FileType latex nnoremap ,lG <plug>(vimtex-status-all)
autocmd FileType latex nnoremap ,lc <plug>(vimtex-clean)
autocmd FileType latex nnoremap ,lC <plug>(vimtex-clean-full)
autocmd FileType latex nnoremap ,lm <plug>(vimtex-imaps-list)
autocmd FileType latex nnoremap ,lx <plug>(vimtex-reload)
autocmd FileType latex nnoremap ,lX <plug>(vimtex-reload-state)
autocmd FileType latex nnoremap ,ls <plug>(vimtex-toggle-main)
autocmd FileType latex nnoremap ,la <plug>(vimtex-context-menu)
