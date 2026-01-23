" TODO Add folding and divide the file into logical blocks
" Colorscheme handling
set termguicolors
colorscheme carbonized-dark

" Filetype plugin
filetype on

" Set mouse only for normal mode
set mouse=n

" Show line numbers properly
set number
set relativenumber

" Switching between buffers without saving
set hidden

" Taller commandline
set cmdheight=2

" Highlight current line
set cursorline

" Turn on the wild menu
set nowildmenu

" By default, ignore case
set ignorecase

" Makes search act like search in modern browsers
set incsearch

" For regular expressions turn magic on
set magic

" Set line wrapping and its navigation
set nowrap linebreak
set showbreak=…

nnoremap <expr> j v:count == 0 ? 'gj' : "\<Esc>".v:count.'j'
nnoremap <expr> j v:count == 0 ? 'gj' : "\<Esc>".v:count.'j'
vnoremap <expr> k v:count == 0 ? 'gk' : "\<Esc>".v:count.'k'
vnoremap <expr> k v:count == 0 ? 'gk' : "\<Esc>".v:count.'k'

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Show matching brackets when text indicator is over them
set showmatch
" How many tenths of a second to blink when matching brackets
set mat=5

" No swap, no backup
set noswapfile
set nobackup

" 1 tab == 2 spaces
" except for the files in which it is overriden in the filetype plugin
set shiftwidth=2
set tabstop=2
set sts=2
set expandtab

" Always show the status line
set laststatus=2

" Show and wrap at 80th column
set colorcolumn=88
set textwidth=88

" Wait for 600ms for the next key in the mapping
set timeoutlen=600

" Formatoptions
set formatoptions-=t
set formatoptions+=cro/qn1j

" Folding
set foldlevel=1
set foldcolumn=2

function! CloseFoldsInnerFirst() abort
  let lnum = line('.')
  let L = foldlevel(lnum)
  if L <= 0
    return
  endif

  " Helper: move left boundary across closed folds correctly
  let s = lnum
  while s > 1
    let prev = s - 1

    " If prev is inside a closed fold, jump to that fold's start
    let fc = foldclosed(prev)
    if fc != -1
      " If that closed fold is still within our target level, include it and continue
      if foldlevel(fc) >= L
        let s = fc
        continue
      else
        break
      endif
    endif

    if foldlevel(prev) >= L
      let s = prev
    else
      break
    endif
  endwhile

  " Helper: move right boundary across closed folds correctly
  let e = lnum
  let last = line('$')
  while e < last
    let nxt = e + 1

    " If nxt is inside a closed fold, jump to that fold's end
    let fc = foldclosed(nxt)
    if fc != -1
      let fe = foldclosedend(nxt)
      " If that closed fold belongs to our target fold, include it wholly and continue
      if foldlevel(fc) >= L
        let e = fe
        continue
      else
        break
      endif
    endif

    if foldlevel(nxt) >= L
      let e = nxt
    else
      break
    endif
  endwhile

  " Collect fold starts inside [s,e], skipping over already-closed children
  let starts = []
  let i = s
  while i <= e
    " Skip closed folds entirely (they're already collapsed; also avoids foldlevel()=0 inside)
    let fc = foldclosed(i)
    if fc != -1
      let i = foldclosedend(i) + 1
      continue
    endif

    let prevL = (i > 1 ? foldlevel(i - 1) : 0)
    let curL  = foldlevel(i)

    " A fold "starts" when level increases; only consider folds at/under current depth
    if curL > prevL && curL >= L
      call add(starts, [curL, i])
    endif

    let i += 1
  endwhile

  " Deepest first; for same depth, bottom-up
  call sort(starts, {a,b -> a[0] == b[0] ? (b[1] - a[1]) : (b[0] - a[0])})

  " Close each fold using :foldclose (no !) semantics via zc
  let view = winsaveview()
  try
    for item in starts
      let ln = item[1]
      if foldclosed(ln) == -1
        call cursor(ln, 1)
        silent! normal! zc
      endif
    endfor
  finally
    call winrestview(view)
  endtry
endfunction

function! CloseFoldsInnerFirst() abort
  let lnum = line('.')
  let L = foldlevel(lnum)
  if L <= 0
    return
  endif

  " Helper: move left boundary across closed folds correctly
  let s = lnum
  while s > 1
    let prev = s - 1

    " If prev is inside a closed fold, jump to that fold's start
    let fc = foldclosed(prev)
    if fc != -1
      " If that closed fold is still within our target level, include it and continue
      if foldlevel(fc) >= L
        let s = fc
        continue
      else
        break
      endif
    endif

    if foldlevel(prev) >= L
      let s = prev
    else
      break
    endif
  endwhile

  " Helper: move right boundary across closed folds correctly
  let e = lnum
  let last = line('$')
  while e < last
    let nxt = e + 1

    " If nxt is inside a closed fold, jump to that fold's end
    let fc = foldclosed(nxt)
    if fc != -1
      let fe = foldclosedend(nxt)
      " If that closed fold belongs to our target fold, include it wholly and continue
      if foldlevel(fc) >= L
        let e = fe
        continue
      else
        break
      endif
    endif

    if foldlevel(nxt) >= L
      let e = nxt
    else
      break
    endif
  endwhile

  " Collect fold starts inside [s,e], skipping over already-closed children
  let starts = []
  let i = s
  while i <= e
    " Skip closed folds entirely (they're already collapsed; also avoids foldlevel()=0 inside)
    let fc = foldclosed(i)
    if fc != -1
      let i = foldclosedend(i) + 1
      continue
    endif

    let prevL = (i > 1 ? foldlevel(i - 1) : 0)
    let curL  = foldlevel(i)

    " A fold "starts" when level increases; only consider folds at/under current depth
    if curL > prevL && curL >= L
      call add(starts, [curL, i])
    endif

    let i += 1
  endwhile

  " Deepest first; for same depth, bottom-up
  call sort(starts, {a,b -> a[0] == b[0] ? (b[1] - a[1]) : (b[0] - a[0])})

  " Close each fold using :foldclose (no !) semantics via zc
  let view = winsaveview()
  try
    for item in starts
      let ln = item[1]
      if foldclosed(ln) == -1
        call cursor(ln, 1)
        silent! normal! zc
      endif
    endfor
  finally
    call winrestview(view)
  endtry
endfunction

noremap <silent> zC :call CloseFoldsInnerFirst()<CR>

