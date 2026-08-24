" TODO Add folding and divide the file into logical blocks
" Colorscheme handling
set termguicolors

augroup color_overrides
  autocmd!
  " autocmd ColorScheme carbonized-dark highlight CursorLine guibg=#3b3b37 gui=underline
  " carbonized-dark predates treesitter's @variable capture, so plain
  " identifiers fall through to Neovim's built-in default link, which
  " resolves to an auto-computed near-white instead of Normal's warm
  " foreground. Re-link it here, alongside the colorscheme it corrects for.
  " autocmd ColorScheme carbonized-dark highlight! link @variable Normal

  " everforest has the same @variable gap as carbonized-dark above.
  " autocmd ColorScheme everforest highlight! link @variable Normal

  " nordfox has the same @variable gap; nordic defines it correctly already.
  autocmd ColorScheme nordfox highlight! link @variable Normal
augroup END

" colorscheme carbonized-dark
" set background=dark
" colorscheme everforest
" reduced_blue tones the Frost blues toward Aurora's warmer accents.
" lua require('nordic').setup({ reduced_blue = true })
" colorscheme nordic
" nordfox's default bg1 (#2e3440) reads a touch light; darkened ~15% here,
" leaving bg0 (statusline/float background) untouched so the two stay
" visually distinct from each other.
" lua require('nightfox').setup({ palettes = { nordfox = { bg1 = "#272c36" } } })
colorscheme nordfox

" Filetype plugin
filetype on

" Enable mouse in normal and visual mode. Visual mode is included to fix a
" race condition where a buffered terminal mouse-release event from a
" focus-click is misinterpreted as <Esc>, aborting the visual selection.
" With mouse=nv Neovim properly consumes these events; the <nop> mappings in
" basic-maps.vim neutralise the side-effect of click-to-reposition in visual.
set mouse=nv

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
set nowrap linebreak
set showbreak=…

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=5

" No swap, no backup
set noswapfile
set nobackup

" Open horizontal splits below the current window
set splitbelow

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

" Folding
set foldlevel=1
set foldcolumn=2


