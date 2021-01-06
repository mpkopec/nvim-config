" TODO Add folding and divide the file into logical blocks
" Colorscheme handling
set termguicolors
colorscheme deep-space

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
set wildmenu

" By default, ignore case
set ignorecase

" Makes search act like search in modern browsers
set incsearch

" For regular expressions turn magic on
set magic

" No line wrapping
set nowrap

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
