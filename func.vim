function g:PlgridLinks(prefix)
  execute '%s/\Vcommit /commit ' . escape(a:prefix, '/\') . '/g'
  execute 'noh'
endfunction
