" Fast saving
nnoremap <space>w :write<cr>
nnoremap <space>d :bdelete<cr>
nnoremap <space>dd :bdelete!<cr>
" memo: exit
nnoremap <space>e :quit<cr>
nnoremap <space>wd :write<cr>:bdelete<cr>
nnoremap <space>we :wq<cr>
nnoremap <space>ee :qa<cr>
nnoremap <space>wee :wqall!<cr>

" Edit and source vimrc
" memo: vim edit
nnoremap <space>ve :edit $MYVIMRC<cr>
" memo: vim vertical split
nnoremap <space>vv :vsplit $MYVIMRC<cr>
" memo: vim load
nnoremap <space>vl :source $MYVIMRC<cr>

" Disable highlight when <space><cr> is pressed
nnoremap <silent> <space><cr> :noh<cr>

" Switch CWD to the directory of the open buffer
nnoremap <space>cd :cd %:p:h<cr>:pwd<cr>

" To open a new empty buffer
" This replaces :tabnew which I used to bind to this mapping
nnoremap <space>T :enew<cr>

" Move to the next buffer
nnoremap <space>l :bnext<CR>

" Move to the previous buffer
nnoremap <space>j :bprevious<CR>

" Quicker shell opening
nmap <space>s :terminal<CR>
