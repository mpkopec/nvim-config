" Split navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Better fold toggling
nnoremap <space> za

" Replace Ctrl-n, Ctrl-p with Ctrl-j and Ctrl-k
" TODO After installing a proper completion engine, this needs to be reverted
inoremap <expr><C-j>  pumvisible() ? "\<C-n>" : "\<C-x><C-n>"
inoremap <expr><C-k>  pumvisible() ? "\<C-p>" : "\<C-x><C-p>"
inoremap <expr><C-l>  pumvisible() ? "\<C-y>" : "\<C-l>"

" With YCM's popup open, plain <CR> either just accepts a navigated-to
" candidate (already live-written into the buffer by <C-j>/<C-k> above) or,
" worse, gets treated by YCM as a text-changing edit and reopens the popup
" instead of breaking the line — <CR> is not one of YCM's own guarded
" stop-completion keys, only <C-y> is. This has to be a <Cmd> mapping, not
" an <expr> one: an <expr> mapping's returned keys are inserted raw and
" unmapped, so "\<C-y>\<CR>" would never reach YCM's real <C-y> mapping —
" the one that actually sets its internal reopen guard; a <Cmd> mapping
" runs its body as an Ex command with none of the <expr> textlock/queuing
" restrictions, so feedkeys(..., 'm') from inside it reaches YCM's guarded
" mapping properly, and the trailing <CR> loops back into this same
" mapping once more, but by then pumvisible() is false, so that second
" pass just inserts the newline.
"
" lexima.vim also claims <CR> for itself, but lazily — only the first
" time Insert mode is entered in the session (self-deleting augroup
" lexima-init in its plugin/lexima.vim) — which is later than this file
" being sourced at startup, so a plain inoremap here would get silently
" overwritten the moment the user first types anything. That setup is
" only deferred to InsertEnter because it lives behind an autoload
" function (lexima#init(), effectively a no-op whose only real job is to
" trigger Vim's autoload mechanism into sourcing autoload/lexima.vim,
" which is what actually installs the default rules as a side effect of
" being loaded). Calling any lexima# function ourselves forces that same
" loading — and thus lexima's own <CR> mapping — to happen right here
" instead, deterministically, before our own mapping below, so there is
" no InsertEnter race left to lose.
call lexima#init()
function! s:YcmDismissPopupAndNewline() abort
  if pumvisible()
    call feedkeys("\<C-y>\<CR>", 'mi')
  else
    " lexima#expand() is the same function lexima's own <CR> mapping would
    " have called; using it here (rather than a bare <CR>) keeps its
    " bracket-expand-to-indented-block behaviour (e.g. "{<CR>}") working.
    " It returns a string built to be typed literally, unmapped — the same
    " way lexima's own generated mapping consumes it (a plain, non-remapped
    " inoremap) — so this is fed with 'n', not 'm'.
    call feedkeys(lexima#expand('<CR>', 'i'), 'ni')
  endif
endfunction
" The Cmd-mapping chain above (and the feedkeys() calls inside it) defers
" screen redraws; without this, lexima's <C-r>=...<CR> expression-register
" trick (called via feedkeys in the non-popup branch above) evaluates
" correctly but its prompt text visibly lingers in the command-line row.
inoremap <silent> <CR> <Cmd>call <SID>YcmDismissPopupAndNewline()<CR><Cmd>redraw<CR>

" Moving lines and groups of them
nnoremap <silent> <A-u> :m .+1<CR>
inoremap <silent> <A-u> <Esc>:m .+1<CR>gi
vnoremap <silent> <A-u> :m '>+1<CR>gv
nnoremap <silent> <A-i> :m .-2<CR>
inoremap <silent> <A-i> <Esc>:m .-2<CR>gi
vnoremap <silent> <A-i> :m '<-2<CR>gv

" Consume mouse-button events in visual mode without acting on them — see
" mouse=nv comment in basic-settings.vim for the full rationale.
vnoremap <LeftMouse>   <nop>
vnoremap <LeftRelease> <nop>

" Better jk navigation with soft-wrapped lines and jump list for count > 1
nnoremap <expr> k v:count == 0 ? 'gk' : v:count > 1 ? "m'".v:count.'k' : v:count.'k'
nnoremap <expr> j v:count == 0 ? 'gj' : v:count > 1 ? "m'".v:count.'j' : v:count.'j'

" Remove trailing whitespace
nnoremap ,ts mm:%s/\s\+$//<cr>:noh<cr>`m

" Highlight but not jump
nnoremap * :keepjumps normal! mi*`i<CR>

" For verilog state machines sequential logic
vnoremap ,rtn :s/\(\s\+\)\(\(\w\+\)_reg\)\(\s\+\)<=\(\s\+\)\w\+;/\1\2\4<=\5\3_next;<CR>

" Make a scratchpad buffer and open it
nnoremap ,s :enew<CR>:setlocal buftype=nofile bufhidden=hide noswapfile<CR>

" Exit terminal mode
" <C-g> is preferred over an <Esc>-based mapping: 'timeoutlen' (600ms, see
" basic-settings.vim) applies to terminal-mode key sequences too, so an
" <Esc><Esc>-style mapping would delay zsh's double-Esc sudo-prefix trick by
" that much every time; a single chord has no such window.
tnoremap <A-n> <C-\><C-n>
tnoremap <C-g> <C-\><C-n>
