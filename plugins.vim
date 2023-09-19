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

" Highlight just yanked text
Plug 'machakann/vim-highlightedyank'

" Useful pair mappings (like moving lines, jumping, etc.)
" Plug 'tpope/vim-unimpaired'

if exists('g:vscode')
  " Easy motion for VSCode
  " Plug 'asvetliakov/vim-easymotion'
else
  " Fuzzy finding, grepping and exploring
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
  Plug 'nvim-telescope/telescope-file-browser.nvim'
  
  " Tag generation
  Plug 'https://github.com/ludovicchabant/vim-gutentags'

  " Snippet plugin
  " Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'make install_jsregexp'} 
  " exec 'source ' .  stdpath('config') . '/plugconf/luasnip.lua'
  if has('python3')
    Plug 'https://github.com/SirVer/ultisnips'
    Plug 'https://github.com/mpkopec/vim-snippets'
    exec 'source ' .  stdpath('config') . '/plugconf/ultisnips.vim'
  endif

  " Python autocomplete
  Plug 'https://github.com/davidhalter/jedi-vim'

  " Colorscheme switcher
  Plug 'https://github.com/xolox/vim-misc.git'
  Plug 'https://github.com/xolox/vim-colorscheme-switcher.git'

  " Text Navigation
  Plug 'unblevable/quick-scope'

  " NeoVim in Firefox
  Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

  " Easymotion
  Plug 'easymotion/vim-easymotion'
  exec 'source ' .  stdpath('config') . '/plugconf/easymotion.vim'

  " Have the file system follow you around
  Plug 'airblade/vim-rooter'

  " Better Syntax Support
  Plug 'sheerun/vim-polyglot'

  " Auto pairs for '(' '[' '{'
  Plug 'jiangmiao/auto-pairs'

  " Closetags
  Plug 'alvan/vim-closetag'

  " Status Line
  "Plug 'glepnir/galaxyline.nvim'

  " Git
  Plug 'airblade/vim-gitgutter'
  Plug 'https://github.com/tpope/vim-fugitive.git'
  Plug 'junegunn/gv.vim'
  Plug 'rhysd/git-messenger.vim'

  " See what keys do like in emacs
  "Plug 'liuchengxu/vim-which-key'

  " Zen mode
  " Plug 'junegunn/goyo.vim'

  " undo time travel
  Plug 'mbbill/undotree'

  " Find and replace
  Plug 'https://github.com/brooth/far.vim'

  " Swap windows
  Plug 'wesQ3/vim-windowswap'

  " Intuitive buffer closing
  Plug 'moll/vim-bbye'

  " Verilog/SystemVerilog
  Plug 'vhda/verilog_systemverilog.vim'

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
