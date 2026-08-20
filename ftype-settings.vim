" Markdown code folding
let g:markdown_folding = 1

" VHDL settings moved to plugconf/vhdl.vim (hex/int conversion, folding,
" instantiation-snippet style flag).

" {{{ XDC
augroup xdc_settings
  autocmd!
  autocmd BufRead,BufNewFile *.xdc setl filetype=xdc
  autocmd FileType xdc setl commentstring=#\ %s
  autocmd FileType xdc setl foldmethod=marker
  autocmd BufWinEnter *.xdc setl foldmethod=marker
augroup END
" }}}

" {{{ Rust
augroup rust_folding
  autocmd!
  " Same reasoning as Python/C: prefer treesitter's foldexpr when a Rust
  " parser is actually available; fall back to foldmethod=indent otherwise.
  autocmd FileType rust call s:SetRustFoldMethod()
augroup END

augroup rust_indent
  autocmd!
  " Neovim's own indent/rust.vim already applies by default via the
  " standard ftplugin/indent.vim mechanism (no change needed to get it) —
  " this only overrides it when a treesitter rust parser is actually
  " available, since its indents.scm is grammar-driven rather than the
  " largely-unmaintained upstream rust.vim indent script (see plugins.vim
  " for the dated-header finding). No fallback branch needed here: if the
  " parser isn't available, indentexpr is simply left at whatever
  " indent/rust.vim already set.
  autocmd FileType rust call s:SetRustTreesitterIndent()
augroup END

function! s:SetRustFoldMethod() abort
  if has('nvim') && luaeval("pcall(vim.treesitter.language.add, 'rust')")
    setlocal foldmethod=expr
    setlocal foldexpr=v:lua.vim.treesitter.foldexpr()
  else
    setlocal foldmethod=indent
  endif
endfunction

function! s:SetRustTreesitterIndent() abort
  if has('nvim') && luaeval("pcall(vim.treesitter.language.add, 'rust')")
    setlocal indentexpr=nvim_treesitter#indent()
  endif
endfunction
" }}}

" {{{ C
augroup c_folding
  autocmd!
  " Prefer treesitter's foldexpr when a C parser is actually available;
  " fall back to foldmethod=indent otherwise (plain Vim, or if the
  " treesitter c parser was never installed) — same reasoning as Python's
  " fold setup below.
  autocmd FileType c call s:SetCFoldMethod()
augroup END

function! s:SetCFoldMethod() abort
  if has('nvim') && luaeval("pcall(vim.treesitter.language.add, 'c')")
    setlocal foldmethod=expr
    setlocal foldexpr=v:lua.vim.treesitter.foldexpr()
  else
    setlocal foldmethod=indent
  endif
endfunction
" }}}

" {{{ Python
function! FormatWithBlack()
  write
  let l:out = system(expand('~') . '/.venv/bin/black --quiet ' . shellescape(expand('%')))
  if v:shell_error
    echohl ErrorMsg
    echo l:out
    echohl None
  else
    edit!
    echo 'black: OK'
  endif
endfunction

augroup python_format
  autocmd!
  autocmd FileType python nnoremap <buffer> ,pf :call FormatWithBlack()<CR>
augroup END

augroup python_folding
  autocmd!
  " indent, not marker: Python's default foldmarker ({{{/}}}) collides with
  " literal triple-brace text that legitimately occurs in f-strings and
  " Jinja2 templates (e.g. f"{{{n}"), producing runaway folds. The prior
  " marker-based approach (lib/fold-markers.vim, ,fm/,fM) is preserved at
  " git tag python-fold-markers-pre-removal.
  "
  " Prefer treesitter's foldexpr when a Python parser is actually available
  " (its fold includes the def/class header line, unlike plain indent
  " folding); fall back to foldmethod=indent otherwise, e.g. on plain Vim or
  " if the treesitter python parser was never installed.
  autocmd FileType python call s:SetPythonFoldMethod()
augroup END

function! s:SetPythonFoldMethod() abort
  if has('nvim') && luaeval("pcall(vim.treesitter.language.add, 'python')")
    setlocal foldmethod=expr
    setlocal foldexpr=v:lua.vim.treesitter.foldexpr()
  else
    setlocal foldmethod=indent
  endif
endfunction
" }}}
