if !exists('g:vscode')
  " only if not in VS Code
  nnoremap ,gs :Gstatus<CR>
  nnoremap ,gc :Gcommit<CR>
  nnoremap ,gu :Gpush<CR>
  nnoremap ,gd :Gpull<CR>
  nnoremap ,gf :Gfetch<CR>
  nnoremap ,gm :Gmerge<CR>
endif
