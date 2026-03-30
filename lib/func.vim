function g:PlgridLinks(prefix)
  let save_pos = getpos(".")
  execute '%s/\Vcommit /commit ' . escape(a:prefix, '/\') . '/g'
  execute 'noh'
  call setpos('.', save_pos)
endfunction
