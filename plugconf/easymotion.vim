" let g:EasyMotion_do_mapping = 0 " Disable default mappings
" " Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1
let g:EasyMotion_verbose = 0
let g:EasyMotion_do_shade = 0

" ,f{char} to move to {char}
map  ,f <Plug>(easymotion-bd-f)
nmap ,f <Plug>(easymotion-overwin-f)

" ,s{char}{char} to move to {char}{char}
nmap ,s <Plug>(easymotion-overwin-f2)

" Move to line
map ,L <Plug>(easymotion-bd-jk)
nmap ,L <Plug>(easymotion-overwin-line)

" Move to word
map  ,w <Plug>(easymotion-bd-w)
nmap ,w <Plug>(easymotion-overwin-w)