let g:EasyMotion_do_mapping = 0 " Disable default mappings
" " Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1
let g:EasyMotion_verbose = 0
let g:EasyMotion_do_shade = 0

" ,f{char} to move to {char}
map  ,mf <Plug>(easymotion-bd-f)
if !exists('g:vscode')
  nmap ,mf <Plug>(easymotion-overwin-f)
endif

" ,s{char}{char} to move to {char}{char}
if !exists('g:vscode')
  nmap ,ms <Plug>(easymotion-overwin-f2)
endif

" Move to line
map ,mL <Plug>(easymotion-bd-jk)
if !exists('g:vscode')
  nmap ,mL <Plug>(easymotion-overwin-line)
endif

" Move to word
map  ,mw <Plug>(easymotion-bd-w)
if !exists('g:vscode')
  " nmap ,w <Plug>(easymotion-overwin-w)
endif
