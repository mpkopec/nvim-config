exec 'source ' .  stdpath('config') . '/plugins.vim'

exec 'source ' .  stdpath('config') . '/basic-settings.vim'
exec 'source ' .  stdpath('config') . '/ftype-settings.vim'
exec 'source ' .  stdpath('config') . '/basic-acmds.vim'
exec 'source ' .  stdpath('config') . '/abbr.vim'
exec 'source ' .  stdpath('config') . '/basic-maps.vim'
exec 'source ' .  stdpath('config') . '/leader-maps.vim'
for s:f in glob(stdpath('config') . '/lib/*.vim', 0, 1)
  exec 'source ' . s:f
endfor

exec 'source ' .  stdpath('config') . '/wsl-clip.vim'

exec 'source ' .  stdpath('config') . '/plugconf/firenvim.vim'
exec 'source ' .  stdpath('config') . '/plugconf/fugitive.vim'
exec 'source ' .  stdpath('config') . '/plugconf/gitgutter.vim'
exec 'source ' .  stdpath('config') . '/plugconf/gutentags.vim'
exec 'source ' .  stdpath('config') . '/plugconf/highlightyank.vim'
exec 'source ' .  stdpath('config') . '/plugconf/jinja.vim'
exec 'source ' .  stdpath('config') . '/plugconf/nerdtree.vim'
exec 'source ' .  stdpath('config') . '/plugconf/switcher.vim'
exec 'source ' .  stdpath('config') . '/plugconf/ultisnips.vim'
exec 'source ' .  stdpath('config') . '/plugconf/verilog_systemverilog.vim'
exec 'source ' .  stdpath('config') . '/plugconf/vim-easy-align.vim'
exec 'source ' .  stdpath('config') . '/plugconf/vim-markdown-toc.vim'
exec 'source ' .  stdpath('config') . '/plugconf/vimtex.vim'
if has('nvim')
  exec 'source ' .  stdpath('config') . '/plugconf/telescope.lua'
  exec 'source ' .  stdpath('config') . '/plugconf/md_section_number.lua'
endif

if exists('g:vscode')
  " VS Code extension
  exec 'source ' .  stdpath('config') . '/vscode-settings.vim'
endif
