let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_completion = 0
let g:ycm_autoclose_preview_window_after_insertion = 0

" Stock <C-e> (revert to originally-typed text, close popup) isn't one of
" YCM's guarded stop-completion keys — only <C-y> ships in the default list
" — so closing via <C-e> alone is itself a text change that YCM's
" TextChangedI listener reads as "still typing" and immediately reopens the
" popup with. Adding <C-e> here routes it through YCM's own
" s:StopCompletion(), which always closes as <C-y> would (accepting
" whatever is currently shown) but sets the reopen-guard flag first.
let g:ycm_key_list_stop_completion = ['<C-y>', '<C-e>']

nnoremap ,gd :YcmCompleter GoTo<CR>
nnoremap ,gre :YcmCompleter GoToReferences<CR>
nnoremap ,gh :YcmCompleter GetDoc<CR>
