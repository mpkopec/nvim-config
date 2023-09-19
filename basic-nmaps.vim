" Split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Replace Ctrl-n, Ctrl-p with Ctrl-j and Ctrl-k
" TODO After installing a proper completion engine, this needs to be reverted

inoremap <expr><C-j>  pumvisible() ? "\<C-n>" : "\<C-x><C-n>"
inoremap <C-k> <C-p>
