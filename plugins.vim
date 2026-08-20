" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin(stdpath('data') . '/plugged')

" Disabled outright — superseded by a dedicated, Vim-compatible plugin/port,
" not treesitter, so this holds under plain Vim too:
" - verilog/systemverilog: vhda/verilog_systemverilog.vim, already the sole
"   active provider via the filetype override in
"   plugconf/verilog_systemverilog.vim — this is defense in depth.
" - xdc: ported into after/syntax/xdc.vim.
" - openscad: vim-openscad already wins precedence today (loads first, and
"   unlike polyglot's systemverilog/jinja2 files it doesn't force-override);
"   this just stops the dead copy from being sourced at all.
" - ansible: polyglot's internal disable-key for syntax/jinja2.vim (oddly
"   filed under 'ansible', not 'jinja2' — checked the is_disabled() call
"   site directly). Also gates polyglot's actual Ansible playbook/inventory
"   support, unused in this repo. Superseded by Glench/Vim-Jinja2-Syntax.
let g:polyglot_disabled = ['verilog', 'systemverilog', 'xdc', 'openscad', 'ansible']

if has('nvim')
  " Only meaningful with treesitter actually installed to replace polyglot's
  " coverage; plain Vim has no treesitter, so polyglot stays authoritative
  " there for all of these.
  call extend(g:polyglot_disabled,
        \ ['python', 'markdown', 'yaml', 'json', 'json5', 'jsonc', 'vhdl'])
  " vhdl's indent (GetVHDLindent(), plugconf/vhdl.vim) and folding
  " (VhdlFoldExpr) stay unaffected: GetVHDLindent() turns out to be a shared
  " upstream community script (Gerald Lai, vim.org #1450) that Neovim's own
  " bundled runtime/indent/vhdl.vim provides too, near-byte-identical to
  " polyglot's copy — so disabling polyglot's vhdl module here just falls
  " back to Neovim's own copy of the same function, and VhdlFoldExpr is
  " untouched either way. Highlighting moves to treesitter (already
  " installed, see plugconf/treesitter.lua).
endif

" Themes
Plug 'https://github.com/rafi/awesome-vim-colorschemes.git'

" Better Comments
Plug 'tpope/vim-commentary'

" Better Join command
Plug 'sk1418/Join'

" Surround
Plug 'tpope/vim-surround'

" Change dates fast
Plug 'tpope/vim-speeddating'

" Change case to title case
Plug 'christoomey/vim-titlecase'

" Convert binary, hex, etc..
Plug 'glts/vim-magnum'
Plug 'glts/vim-radical'

" Repeat stuff
Plug 'tpope/vim-repeat'

" Better highlighting matching text
Plug 'andymass/vim-matchup'

" Highlight just yanked text
Plug 'machakann/vim-highlightedyank'

" Jinja2 templates (only dialect in use here — no plain Jinja/Nunjucks)
Plug 'Glench/Vim-Jinja2-Syntax'

" LaTeX support
Plug 'lervag/vimtex'

" Useful pair mappings (like moving lines, jumping, etc.)
" Plug 'tpope/vim-unimpaired'

if has('nvim')
  " Fuzzy finding, grepping and exploring
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
  Plug 'nvim-telescope/telescope-file-browser.nvim'

  " Markdown heading numbering
  Plug 'whitestarrain/md-section-number.nvim'

  " Syntax-tree-based highlighting/folding
  " master, not main: main requires vim.list, not present until after Nvim 0.11
  Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'master', 'do': ':TSUpdate' }
endif

" NERDTree
Plug 'preservim/nerdtree' |
      \ Plug 'Xuyuanp/nerdtree-git-plugin'

" Tag generation
Plug 'https://github.com/ludovicchabant/vim-gutentags'

" Snippet and completion plugin
" Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*', 'do': 'make install_jsregexp'} 
" exec 'source ' .  stdpath('config') . '/plugconf/luasnip.lua'
if has('python3')
  Plug 'SirVer/ultisnips', { 'branch': 'master' }
  Plug 'honza/vim-snippets'
  exec 'source ' .  stdpath('config') . '/plugconf/ultisnips.vim'

  Plug 'https://github.com/ycm-core/YouCompleteMe', { 'do': 'python3 install.py' }
  exec 'source ' .  stdpath('config') . '/plugconf/ycm.vim'

  " Plug 'https://github.com/davidhalter/jedi-vim'
  " exec 'source ' .  stdpath('config') . '/plugconf/jedi-vim.vim'

  Plug 'pixelneo/vim-python-docstring'
  exec 'source ' .  stdpath('config') . '/plugconf/vim-python-docstring.vim'
endif

" Text Navigation
Plug 'unblevable/quick-scope'

" OpenSCAD
Plug 'sirtaj/vim-openscad'

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

" Easy aligning
Plug 'junegunn/vim-easy-align'

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

" Markdown ToC
Plug 'mzlogin/vim-markdown-toc'

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

call plug#end()

" Automatically install missing plugins on startup
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif
