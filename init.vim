" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin(stdpath('data') . '/plugged')

Plug 'https://github.com/tpope/vim-fugitive.git'
Plug 'https://github.com/rafi/awesome-vim-colorschemes.git'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'kevinoid/vim-jsonc'

" Initialize plugin system
call plug#end()

exec 'source ' .  stdpath('config') . '/basic-settings.vim'
exec 'source ' .  stdpath('config') . '/basic-nmaps.vim'
exec 'source ' .  stdpath('config') . '/leader-nmaps.vim'
exec 'source ' .  stdpath('config') . '/fugitive-config.vim'
