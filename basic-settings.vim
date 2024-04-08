" TODO Add folding and divide the file into logical blocks
" Colorscheme handling
set termguicolors
colorscheme carbonized-dark

" Show line numbers properly
set number
set relativenumber

" Switching between buffers without saving
set hidden

" Taller commandline
set cmdheight=2

" Highlight current line
set cursorline

" Turn on the wild menu
set nowildmenu

" By default, ignore case
set ignorecase

" Makes search act like search in modern browsers
set incsearch

" For regular expressions turn magic on
set magic

" Set line wrapping and its navigation
set nowrap linebreak nolist
set showbreak=…

vmap j gj
vmap k gk
nmap j gj
nmap k gk

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=5

" No swap, no backup
set noswapfile
set nobackup

" 1 tab == 2 spaces
" except for the files in which it is overriden in the filetype plugin
set shiftwidth=2
set tabstop=2
set sts=2
set expandtab

" Always show the status line
set laststatus=2

" Show and wrap at 80th column
set colorcolumn=88
set textwidth=88

" Wait for 600ms for the next key in the mapping
set timeoutlen=600

" Formatoptions
set formatoptions-=t
set formatoptions+=cro/qn1j
