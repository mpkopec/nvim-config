" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin(stdpath('data') . '/plugged')

" Themes
Plug 'https://github.com/rafi/awesome-vim-colorschemes.git'

" Better Comments
Plug 'tpope/vim-commentary'

" Surround
Plug 'tpope/vim-surround'

" Change dates fast
Plug 'tpope/vim-speeddating'

" Convert binary, hex, etc..
Plug 'glts/vim-radical'

" Repeat stuff
Plug 'tpope/vim-repeat'

" Text Navigation
Plug 'unblevable/quick-scope'

" Highlight just yanked text
Plug 'machakann/vim-highlightedyank'

if exists('g:vscode')
  " Easy motion for VSCode
  Plug 'asvetliakov/vim-easymotion'
else
  " NeoVim in Firefox
  Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

  " Easymotion
  Plug 'easymotion/vim-easymotion'

  " Have the file system follow you around
  Plug 'airblade/vim-rooter'

  " Better Syntax Support
  Plug 'sheerun/vim-polyglot'

  " Auto pairs for '(' '[' '{'
  Plug 'jiangmiao/auto-pairs'

  " Closetags
  Plug 'alvan/vim-closetag'

  " Status Line
  Plug 'glepnir/galaxyline.nvim'

  " Ranger file explorer in a floating window
  Plug 'kevinhwang91/rnvimr'

  " Git
  Plug 'airblade/vim-gitgutter'
  Plug 'https://github.com/tpope/vim-fugitive.git'
  Plug 'junegunn/gv.vim'
  Plug 'rhysd/git-messenger.vim'

  " See what keys do like in emacs
  Plug 'liuchengxu/vim-which-key'

  " Zen mode
  Plug 'junegunn/goyo.vim'

  " undo time travel
  Plug 'mbbill/undotree'

  " Find and replace
  Plug 'https://github.com/brooth/far.vim'

  " Smooth scroll
  Plug 'psliwka/vim-smoothie'

  " Swap windows
  Plug 'wesQ3/vim-windowswap'

  " Intuitive buffer closing
  Plug 'moll/vim-bbye'

  " Neovim in Browser
  " For later
  "Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

  " Markdown Preview
  " NN in the pure editor
  "Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & npm install'  }
endif

call plug#end()

" Automatically install missing plugins on startup
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif
