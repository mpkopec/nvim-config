# TODO: UltiSnips nested-snippet `$0` select-mode bug (root cause found, not yet fixed)

Status as of 2026-08-04: root cause identified with log evidence from the
live plugin process. Not yet fixed — no upstream report filed, no
snippet-level workaround applied. Debugging concluded for this session; the
instrumentation described below has been reverted from the installed plugin
copy (it was never part of this repo, only a local edit under
`~/.local/share/nvim/plugged/ultisnips/`).

## Symptom

Expanding a snippet, then expanding a *second* snippet inside one of the
first snippet's placeholder tabstops, then jumping forward through the rest
of the outer snippet's tabstops: the outer snippet's own final tabstop
(`$0`, whether implicit or explicit) does not land as a zero-width
Insert-mode cursor the way a normal terminal tabstop does. Instead it lands
as a *wide* Select-mode highlight spanning the entire nested expansion, and
every subsequent jump-forward press just re-highlights the same span again
rather than leaving the snippet. The only way out is `<Esc>` to Normal mode
and repositioning manually.

Reproduced concretely with this repo's `UltiSnips/vhdl.snippets`:
`io<expand>` → fill name → jump → skip direction → jump (now on tab 3,
`${3:std_logic}`) → `slv<expand>` (nested) → fill the vector width → jump →
skip the `downto 0` default → jump (lands correctly on nested `slv`'s own
`$0`) → jump again (this is where it breaks — lands on `io`'s own `$0`, and
that's the bad landing).

## Root cause

Confirmed by patching `_jump()` in
`ultisnips/pythonx/UltiSnips/snippet_manager.py` to log every tabstop-0
landing's `(start, end)` position and the mode before/after, to
`/tmp/ultisnips_debug.log` (no live pdb connection needed — a blocking
remote-pdb breakpoint was tried first but proved too fragile to rely on, see
below). One full `io`→`slv` repro produced:

```
landing #1 BEFORE: trigger='slv' active_depth=2 ntab=(16,41)-(16,41) mode='n'
call end: jumped=True mode='n' active_depth=1
landing #2 BEFORE: trigger='io'  active_depth=1 ntab=(16,13)-(16,41) mode='i'
call end: jumped=True mode='i' active_depth=0
```

Landing #1 is the nested `slv` snippet's own `$0`: a genuine zero-width
range, `(16,41)-(16,41)`. This is the well-behaved case — a normal
Insert-mode cursor, no highlight.

Landing #2 is the outer `io` snippet's own `$0` — the buggy one. Its range
is `(16,13)-(16,41)`, **not zero-width**. Column 13 is exactly where `io`'s
own tabstop 3 (`${3:std_logic}`, the placeholder that hosted the nested
expansion) originally started. Column 41 is exactly where the nested `slv`
snippet's own `$0` ended up (landing #1's position). That is not a
coincidence: `select_next_tab()` on the outer snippet is not returning an
independent, zero-width `$0` position at all — it is returning **tabstop
3's own placeholder range**, which grew from 9 columns (`std_logic`) to 28
columns as the nested snippet expanded inside it. `vim_helper.select()` then
does exactly what it is told and highlights that whole grown range, landing
in Select mode instead of collapsing to a bare Insert-mode cursor.

So: when a snippet's own `$0` sits immediately after a tabstop that later
hosts a nested-snippet expansion, UltiSnips' tabstop bookkeeping conflates
the parent snippet's terminal `$0` with the now-grown host tabstop, instead
of tracking `$0` as a genuinely separate zero-width position past it. This
held regardless of whether `$0` was implicit or explicit in the snippet
body (see Mitigations below) — the conflation happens at the tabstop-object
level, not from anything textual in how `$0` is written.

This is treated as a real UltiSnips defect, not a symptom of this repo's
own config: it reproduces with a `<C-x><C-s>`/`<C-l>` trigger scheme, but
nothing about the mechanism above depends on which keys are bound to
expand/jump.

## Investigated and ruled out as causes

- **`<C-l>` key-mapping collision** (a stale pre-YCM `basic-maps.vim`
  mapping that re-emitted a literal `<C-l>` on its non-popup fallback
  branch, inserting a stray `^L`): real bug, fixed
  (`inoremap <C-l> <Nop>` in `basic-maps.vim`), confirmed working, but
  **separate from and insufficient to fix** the select-mode bug described
  here.
- **The custom VHDL structural foldexpr** (`plugconf/vhdl.vim`,
  `s:BuildVhdlFoldCache()` on every `TextChanged`/`TextChangedI`/
  `InsertLeave`): investigated as a possible aggravating factor, ruled out
  — the user recalls this bug predating that autocmd's existence.
  Confirmed via `:verbose smap <C-l>`/`:verbose imap <C-l>` while stuck that
  no buffer-local UltiSnips mapping remains at the stuck moment either — the
  bug is a bad landing, not a stuck jump-forward loop.
- **File size/complexity**: tested with buffers from a few lines up to a
  101-line synthetic realistic VHDL file (60 signals + a process block); no
  effect.
- **Explicit vs. implicit `$0`**: `vhdl.snippets`' declaration and
  type-conversion snippets were patched to give `$0` explicitly at the end
  of every body (instead of relying on UltiSnips' implicit end-of-snippet
  `$0`). Confirmed via testing this introduced no regressions in the
  well-behaved case, but did **not** fix the select-mode bug — consistent
  with the root cause above, since the conflation is at the tabstop-object
  level regardless of whether `$0` is spelled out.

## A dead end worth recording: RemotePDB is too fragile for this bug

UltiSnips ships a remote-pdb debug server
(`g:UltiSnipsDebugServerEnable`, `pythonx/UltiSnips/remote_pdb.py`). It was
tried first, before the log-based approach above, and abandoned:

- `RemotePDB.start_server()` guards with `if self._pdb is not None: return`
  — the server is a **process-wide singleton that only supports one live
  session**. Continuing past a breakpoint with `c` without a clean `quit`
  leaves a stale, already-closed connection; the next breakpoint hit reuses
  it and crashes with `OSError: [Errno 107] Transport endpoint is not
  connected` trying to shut down an already-dead socket.
- A counter-based workaround (skip the first, known-good `$0` landing,
  break only on the second) was tried to sidestep the reuse bug, but on a
  live-editor repro the breakpoint silently never fired at all with no
  error — later traced to the user simply not having re-enabled
  `g:UltiSnipsDebugServerEnable` after restarting nvim to pick up the
  patched module, not a flaw in the counter logic itself.
- Net lesson: for a bug this sensitive to exact interactive timing, a
  **non-blocking append-to-file log** (as used successfully above) is far
  more robust than a live blocking pdb session — it survives across
  multiple repro attempts, needs no per-run server re-enable step, and
  gives useful data even on runs where the bug doesn't reproduce.

## Minimal reproduction setup (ready to use when filing upstream)

Self-contained, no dependency on the rest of this repo's config (no
foldexpr, no YCM, no custom mappings beyond the three variables below) —
isolates the bug to UltiSnips itself.

**`/tmp/ultisnips-repro/init.vim`:**
```vim
set nocompatible
set runtimepath+=~/.local/share/nvim/plugged/ultisnips
filetype plugin on
syntax on

let g:UltiSnipsExpandTrigger = "<c-x><c-s>"
let g:UltiSnipsJumpForwardTrigger = "<c-l>"
let g:UltiSnipsJumpBackwardTrigger = "<c-h>"
let g:UltiSnipsSnippetDirectories = ['/tmp/ultisnips-repro/UltiSnips']
```

**`/tmp/ultisnips-repro/UltiSnips/reprotest.snippets`:**
```
snippet outer "outer snippet, hosts nesting in tab 3"
${1:name} : ${2:mid} ${3:placeholder};$0
endsnippet

snippet inner "inner snippet, expands inside outer's tab 3"
NEST(${1:a} to ${2:b})$0
endsnippet
```

**Reproduction steps:**
```
nvim -u /tmp/ultisnips-repro/init.vim /tmp/ultisnips-repro/repro.txt
:set filetype=reprotest
i
outer<C-x><C-s>      " expand outer
alice<C-l>            " fill tab 1, jump
bob<C-l>               " fill tab 2, jump (now on tab 3, "placeholder" selected)
inner<C-x><C-s>       " expand inner, nested inside outer's tab 3
1<C-l>                  " fill inner's tab 1, jump
<C-l>                   " skip inner's tab 2, jump — lands on inner's own $0 (correct: zero-width)
<C-l>                   " jump again — expected: outer's own $0, zero-width
                         " observed: Select-mode highlight spanning from
                         " tab 3's original start to inner's $0 end
```

At the last `<C-l>`, `mode()` should report `n`/`i` (a bare cursor) but
instead reports `s`, with the whole nested-expansion span highlighted.

**To capture the same log evidence again if needed:** patch `_jump()` in
`~/.local/share/nvim/plugged/ultisnips/pythonx/UltiSnips/snippet_manager.py`
(the `if ntab is not None and ntab.number == 0:` branch, right after
`ntab = self._current_snippet.select_next_tab(jump_direction)`) to append
`ntab.start`/`ntab.end`/`self._current_snippet.snippet.trigger` to a file —
see the log format reproduced above. Remember to `rm -f
__pycache__/snippet_manager.cpython-*.pyc` after editing, since a
already-running nvim process's Python interpreter won't pick up the change
without a full restart.

## To file upstream

1. Confirm the minimal repro above still reproduces on a clean UltiSnips
   checkout (not just this installed copy) — not yet done.
2. Check the UltiSnips issue tracker for existing reports of nested
   snippets losing `$0` zero-width status — not yet searched.
3. If none exists, file with: the symptom description, the minimal repro
   files/steps above, and the root-cause paragraph above (tabstop 3's grown
   placeholder range being returned in place of `$0`'s own zero-width
   position).

## Possible local workaround (not yet implemented)

Insert a real (non-`$0`) dummy tabstop between the nesting-host tabstop and
the snippet's own final `$0` in the affected snippets (`io`, `si`, and any
other declaration/type-conversion snippet in `UltiSnips/vhdl.snippets` that
both hosts nesting and is immediately followed by `$0`), so `$0` no longer
sits adjacent to a tabstop that can host nesting. Deferred — not requested
this session.
