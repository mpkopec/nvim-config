let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_completion = 0
let g:ycm_autoclose_preview_window_after_insertion = 0

nnoremap ,gd :YcmCompleter GoTo<CR>
nnoremap ,gre :YcmCompleter GoToReferences<CR>
nnoremap ,gh :YcmCompleter GetDoc<CR>
