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

" Change case to title case
Plug 'christoomey/vim-titlecase'

" Convert binary, hex, etc..
Plug 'glts/vim-radical'

" Repeat stuff
Plug 'tpope/vim-repeat'

" Highlight just yanked text
Plug 'machakann/vim-highlightedyank'

" Jinja2 templates
Plug 'lepture/vim-jinja'

" LaTeX support
Plug 'lervag/vimtex'

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

  " NERDTree
  Plug 'preservim/nerdtree' |
    \ Plug 'Xuyuanp/nerdtree-git-plugin'
  
  " Tag generation
  Plug 'https://github.com/ludovicchabant/vim-gutentags'

  " Snippet and completion plugin
  " Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'make install_jsregexp'} 
  " exec 'source ' .  stdpath('config') . '/plugconf/luasnip.lua'
  if has('python3')
    Plug 'https://github.com/SirVer/ultisnips'
    Plug 'https://github.com/mpkopec/vim-snippets'
    exec 'source ' .  stdpath('config') . '/plugconf/ultisnips.vim'
    
    Plug 'https://github.com/ycm-core/YouCompleteMe'
    exec 'source ' .  stdpath('config') . '/plugconf/ycm.vim'

    " Plug 'https://github.com/davidhalter/jedi-vim'
    " exec 'source ' .  stdpath('config') . '/plugconf/jedi-vim.vim'

    Plug 'pixelneo/vim-python-docstring'
    exec 'source ' .  stdpath('config') . '/plugconf/vim-python-docstring.vim'
  endif

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
  
  " Different language formatter support
  Plug 'vim-autoformat/vim-autoformat'

  " Auto pairs for '(' '[' '{'
  Plug 'cohama/lexima.vim'

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
