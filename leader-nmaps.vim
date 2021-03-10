" Fast saving
nnoremap ,w :write<cr>
nnoremap ,d :bdelete<cr>
nnoremap ,dd :bdelete!<cr>
" memo: exit
nnoremap ,e :quit<cr>
nnoremap ,wd :write<cr>:bdelete<cr>
nnoremap ,we :wq<cr>
nnoremap ,ee :qa<cr>
nnoremap ,wee :wqall!<cr>

" Edit and source vimrc
" memo: vim edit
nnoremap ,ve :edit $MYVIMRC<cr>
" memo: vim vertical split
nnoremap ,vv :vsplit $MYVIMRC<cr>
" memo: vim load
nnoremap ,vl :source $MYVIMRC<cr>

" Disable highlight when ,<cr> is pressed
nnoremap <silent> ,<cr> :noh<cr>

" Switch CWD to the directory of the open buffer
nnoremap ,cd :cd %:p:h<cr>:pwd<cr>

" To open a new empty buffer
" This replaces :tabnew which I used to bind to this mapping
nnoremap ,T :enew<cr>

" Move to the next buffer
nnoremap ,l :bnext<CR>

" Move to the previous buffer
nnoremap ,j :bprevious<CR>

" Quicker shell opening
nnoremap ,t :terminal<CR>

" Copy whole file to clipboard
" memo: Ctrl-A
nnoremap ,ca mmggVG"+y`m
