" Split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Replace Ctrl-n, Ctrl-p with Ctrl-j and Ctrl-k
" TODO After installing a proper completion engine, this needs to be reverted

" inoremap <expr><C-j>  pumvisible() ? "\<C-n>" : "\<C-x><C-n>"
" inoremap <expr><C-k>  pumvisible() ? "\<C-p>" : "\<C-x><C-p>"
inoremap <expr><C-l>  pumvisible() ? "\<C-y>" : "\<C-l>"

" Moving lines and groups of them
nnoremap <silent> <C-i> :m .+1<CR>==
inoremap <silent> <C-i> <Esc>:m .+1<CR>==gi
vnoremap <silent> <C-i> :m '>+1<CR>gv=gv
nnoremap <silent> <C-u> :m .-2<CR>==
inoremap <silent> <C-u> <Esc>:m .-2<CR>==gi
vnoremap <silent> <C-u> :m '<-2<CR>gv=gv

" Remove trailing whitespace
nnoremap ,ts mm:%s/\s\+$//<cr>:noh<cr>`m

" Highlight but not jump
nnoremap * :keepjumps normal! mi*`i<CR>

" For verilog state machines sequential logic
vnoremap ,rtn :s/\(\s\+\)\(\(\w\+\)_reg\)\(\s\+\)<=\(\s\+\)\w\+;/\1\2\4<=\5\3_next;<CR>
