fun! TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

let filePtrns2Trim = ["*.v", "*.py"]
for f in filePtrns2Trim
  execute "autocmd BufWritePre " . f . " :call TrimWhitespace()"
endfor

" Wrapping and spelling
let file_patterns_wrap = ["tex", "bib", "markdown"]
for f in file_patterns_wrap
  execute "autocmd FileType " . f . " setlocal wrap"
  execute "autocmd FileType " . f . " setlocal spell"
endfor

autocmd FileType python set shiftwidth=4
autocmd FileType python set tabstop=4
autocmd FileType python set sts=4
autocmd FileType python set expandtab

" Indentation guides
set list
" Update the guides after every change to the shiftwidth option
autocmd OptionSet shiftwidth execute 'setlocal listchars=trail:·,tab:│\ ,leadmultispace:┆' . repeat('\ ', &sw - 1)
" Start the guides after loading the buffer as well
autocmd BufWinEnter * execute 'setlocal listchars=trail:·,tab:│\ ,leadmultispace:┆' . repeat('\ ', &sw - 1)

autocmd BufReadPost *.tex execute "setlocal nolist"
autocmd BufReadPost *.bib execute "setlocal nolist"

autocmd FileType openscad setl commentstring=//\ %s


" Claude Code's Ctrl-G ("edit prompt in $EDITOR") file quotes Claude's last
" response between two '# ───' marker lines, natively truncated to its last
" 50 lines (a compiled-in limit). The functions below splice the untruncated
" final message back in, read straight from the session's own transcript, so
" a long reply can be quoted piecemeal while writing the answer. The marker
" block only exists when Claude Code's '/config' toggle "Show last response in
" external editor" (externalEditorContext) is on.
"
" Claude Code passes no session id to the editor's environment, so the session
" is found through process ancestry instead: every live Claude Code process
" registers itself in ~/.claude/sessions/<pid>.json ({sessionId, procStart,
" ...}), and the editor is a descendant of that process. The registry and the
" transcript layout are both undocumented internals; if either changes, the
" splice silently does nothing and the native '(earlier output truncated)'
" marker stays visible.

" Returns the session id of the nearest Claude Code ancestor, or '' if none.
"
" The walk climbs more than one level because Neovim (0.10+) runs as two
" processes: Vimscript executes in the 'nvim --embed' server, whose parent is
" the TUI client, whose parent is Claude Code. Each /proc/<pid>/stat is parsed
" after the last ')' because the comm field in parentheses may itself contain
" spaces or parentheses; after it, index 1 is the parent pid (stat field 4)
" and index 19 the process start time in clock ticks (field 22).
"
" The registry keeps files of long-dead sessions, and the kernel reuses pids,
" so a stale file can name a pid that now belongs to an unrelated ancestor
" (e.g. the TUI client). Matching procStart against the live start time
" rejects such a file deterministically.
function! s:ClaudeSessionId() abort
  let l:pid = getpid()
  while l:pid > 1 && filereadable('/proc/' . l:pid . '/stat')
    let l:fields = split(matchstr(readfile('/proc/' . l:pid . '/stat')[0], '.*)\s\zs.*'))
    let l:registry = expand('~/.claude/sessions/') . l:pid . '.json'
    if filereadable(l:registry)
      let l:entry = json_decode(join(readfile(l:registry)))
      if string(get(l:entry, 'procStart', '')) ==# string(l:fields[19])
        return get(l:entry, 'sessionId', '')
      endif
    endif
    let l:pid = str2nr(l:fields[1])
  endwhile
  return ''
endfunction

" Returns the text of the session's last assistant message that contains any
" text, as a list of lines, or [] if none is found.
"
" One API message is stored as several transcript entries (one per content
" block: thinking, text, tool_use) sharing the same message.id, so the walk
" goes backward from the end, latches onto the id of the first entry that has
" a text block, and collects text from every entry with that id until a
" different assistant message appears. Lines without the substring
" '"assistant"' are skipped before decoding, since large tool results and
" attachments make up most of a transcript and cannot be assistant entries.
function! s:ClaudeLastMessage(session_id) abort
  let l:transcripts = glob('~/.claude/projects/*/' . a:session_id . '.jsonl', 0, 1)
  if empty(l:transcripts) | return [] | endif

  let l:message_id = ''
  let l:texts = []
  for l:raw in reverse(readfile(l:transcripts[0]))
    if stridx(l:raw, '"assistant"') < 0 | continue | endif
    let l:entry = json_decode(l:raw)
    if get(l:entry, 'type', '') !=# 'assistant' || get(l:entry, 'isSidechain', v:false)
      continue
    endif
    let l:id = get(l:entry.message, 'id', '')
    if !empty(l:message_id) && l:id !=# l:message_id | break | endif
    let l:blocks = filter(copy(get(l:entry.message, 'content', [])),
          \ 'type(v:val) == v:t_dict && get(v:val, "type", "") ==# "text"')
    if empty(l:blocks) | continue | endif
    let l:message_id = l:id
    call extend(l:texts, reverse(map(l:blocks, 'v:val.text')))
  endfor
  return split(join(reverse(l:texts), "\n\n"), "\n", 1)
endfunction

function! ClaudeInjectFullResponse() abort
  let l:header_line = search('^# .*Claude.s last response', 'nw')
  let l:footer_line = search('^# .*Write your reply below', 'nw')
  if l:header_line == 0 || l:footer_line <= l:header_line | return | endif

  try
    let l:session_id = s:ClaudeSessionId()
    let l:message = empty(l:session_id) ? [] : s:ClaudeLastMessage(l:session_id)
  catch
    return
  endtry
  if empty(l:message) | return | endif

  " Claude Code flushes transcript entries a few seconds late, so a Ctrl-G
  " pressed right after a reply can find the transcript one message behind,
  " whereas the native quote is always current. Its last non-empty line must
  " therefore appear in the extracted message's last non-empty line; on a
  " mismatch the native quote is kept rather than replaced with an older
  " message. Containment rather than equality tolerates a native line wrap.
  let l:native = filter(map(getline(l:header_line + 1, l:footer_line - 1),
        \ 'trim(substitute(v:val, "^#", "", ""))'), '!empty(v:val)')
  let l:extracted = filter(map(copy(l:message), 'trim(v:val)'), '!empty(v:val)')
  if empty(l:native) || empty(l:extracted) || stridx(l:extracted[-1], l:native[-1]) < 0
    return
  endif

  let l:quoted = map(l:message, 'empty(v:val) ? "#" : "# " . v:val')
  if l:footer_line - l:header_line > 1
    silent execute (l:header_line + 1) . ',' . (l:footer_line - 1) . 'delete _'
  endif
  call append(l:header_line, l:quoted)
  call cursor(l:header_line + len(l:quoted) + 2, 1)
  " The splice is not an edit of the user's: leaving the buffer unmodified
  " keeps a plain :q working when the user decides not to reply.
  setlocal nomodified
endfunction

" Vim's ** does not match zero directories, hence the two patterns: Claude
" Code writes the file under /tmp/claude-<uid>/, older versions in /tmp/.
autocmd BufReadPost /tmp/claude-prompt-*.md,/tmp/**/claude-prompt-*.md call ClaudeInjectFullResponse()
