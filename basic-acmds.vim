fun! TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

let filePtrns2Trim = ["*.v", "*.py"]
for f in filePtrns2Trim
  execute "autocmd BufWritePre " . f . " :call TrimWhitespace()"
endfor

let file_patterns_wrap = ["tex", "bib"]
for f in file_patterns_wrap
  execute "autocmd FileType " . f . " setlocal wrap"
endfor
