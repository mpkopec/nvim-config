exec 'source ' .  stdpath('config') . '/plugins.vim'

exec 'source ' .  stdpath('config') . '/basic-settings.vim'
exec 'source ' .  stdpath('config') . '/abbr.vim'
exec 'source ' .  stdpath('config') . '/basic-nmaps.vim'
exec 'source ' .  stdpath('config') . '/leader-nmaps.vim'

exec 'source ' .  stdpath('config') . '/plugconf/easymotion.vim'
exec 'source ' .  stdpath('config') . '/plugconf/firenvim.vim'

if exists('g:vscode')
  " VS Code extension
  exec 'source ' .  stdpath('config') . '/vscode-settings.vim'
  exec 'source ' .  stdpath('config') . '/plugconf/highlightyank.vim'
endif
