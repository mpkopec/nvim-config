if !exists('g:vscode')
  " only if not in VS Code
  nnoremap ,gs :Git<CR>
  nnoremap ,gc :Git commit<CR>
  nnoremap ,gu :Git push<CR>
  nnoremap ,gd :Git pull<CR>
  nnoremap ,gf :Git fetch<CR>
  nnoremap ,gm :Git merge<CR>
endif
