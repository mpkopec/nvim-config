exec 'source ' .  stdpath('config') . '/plugins.vim'

exec 'source ' .  stdpath('config') . '/basic-settings.vim'
exec 'source ' .  stdpath('config') . '/abbr.vim'
exec 'source ' .  stdpath('config') . '/basic-nmaps.vim'
exec 'source ' .  stdpath('config') . '/leader-nmaps.vim'
exec 'source ' .  stdpath('config') . '/func.vim'

exec 'source ' .  stdpath('config') . '/plugconf/easymotion.vim'
exec 'source ' .  stdpath('config') . '/plugconf/firenvim.vim'
exec 'source ' .  stdpath('config') . '/plugconf/fugitive.vim'
exec 'source ' .  stdpath('config') . '/plugconf/highlightyank.vim'
exec 'source ' .  stdpath('config') . '/plugconf/switcher.vim'

if exists('g:vscode')
  " VS Code extension
  exec 'source ' .  stdpath('config') . '/vscode-settings.vim'
endif
