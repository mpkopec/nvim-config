# TODO: Ctrl-G full-response injection (parked, feature fully reverted)

Status as of 2026-08-04: **the entire feature has been removed** from both
repos involved (this repo and `claude-setup`) at the user's request, to get
a clean tree for unrelated work. This note is the complete save-state for
picking it back up later — nothing described below currently exists in
either repo.

## What the feature was

Claude Code's built-in Ctrl-G ("edit in $EDITOR") view of "Claude's last
response" truncates natively to its last 50 lines (`$Fd=50`, a compiled-in
literal in the installed binary — confirmed not configurable via any
setting, env var, or CLI flag). The feature worked around this: a `Stop`
hook dumped the full, untruncated text of every reply to a temp file, and
an nvim autocmd spliced that file's content into the Ctrl-G buffer in place
of the native truncated section.

Two pieces, two repos:
- **`claude-setup`**: `global/hooks/inject-last-response.sh`, registered as
  a `Stop` hook in `global/settings.json` (synced to the live
  `~/.claude/settings.json`).
- **This repo**: `ClaudeInjectFullResponse()` + a `BufReadPost` autocmd in
  `basic-acmds.vim`.

It also depends on a **native Claude Code setting**, not owned by either
repo: the `/config` toggle "Show last response in external editor"
(`externalEditorContext`). Without it, Claude Code never writes the
`# ─── Claude's last response ───` / `# ─── Write your reply below this
line ───` marker block into the Ctrl-G prompt file at all, so there is
nothing for the injection to find. **This toggle was left ON** when the
feature was reverted — it's a global preference, not part of either repo,
and turning it off wasn't part of this cleanup. If picking this feature
back up, check `/config` first; if it's already on, that part needs no
action.

## Root-cause history (three fixed, one open by design)

1. **Stale autocmd path pattern.** Claude Code writes Ctrl-G prompt files
   to `/tmp/claude-<uid>/claude-prompt-<uuid>.md`, not the flat
   `/tmp/claude-prompt-*.md` originally matched. Fixed with two
   comma-separated patterns (`/tmp/claude-prompt-*.md,/tmp/**/claude-prompt-*.md`)
   because vim's `**` doesn't match zero intermediate path components.
2. **The `/config` toggle** must be on (see above).
3. **The hook script itself** didn't exist until it was written and wired
   up as a `Stop` hook.
4. **Global (machine-wide) temp path race**, found and designed around in
   this session (2026-08-04) but never implemented before the revert — see
   below.

## The open design problem: cross-session collisions

The hook's output was a single hardcoded path, `/tmp/claude_last_response.md`,
shared by every Claude Code session on the machine, written by whichever
session's `Stop` event fires last. Confirmed live: this investigating
session and a separate test terminal, both `cwd`'d into this same repo,
raced on that file within about a second of each other, and the test
terminal read a stale/absent result instead of its own reply.

Investigated and ruled out as fixes:
- **Per-session env var**: confirmed by reading the installed binary
  (`Dmt()`, the function that spawns `$EDITOR` via
  `NFd.spawnSync(a, [...l, e], {stdio: "inherit"})`) that Claude Code passes
  **no extra environment variables** to the spawned editor — the child just
  inherits the parent's environment unchanged. No session id is exposed
  there.
- **Prompt filename as an identity key**: the `<uuid>` in
  `claude-prompt-<uuid>.md` is a fresh `crypto.randomUUID()` per invocation
  (confirmed via `srr()` in the binary and empirically — the value never
  appears anywhere in any transcript), unrelated to session id. It only
  resembles a session id because both happen to be v4 UUIDs.
- **Open file descriptor on the parent process**: checked `/proc/<pid>/fd/`
  on live `claude` processes hoping to find an open handle to the session's
  own `.jsonl` transcript (which would trivially yield the session id).
  Empty on every process checked — Claude Code reopens/appends the
  transcript per write rather than holding it open.
- **Another hook event**: the full canonical hook list in the binary is
  `PreToolUse`, `PostToolUse`, `Notification`, `PreCompact`, `SessionStart`,
  `SessionEnd`, `Stop`, `SubagentStart`, `SubagentStop`, `UserPromptSubmit`.
  None fire at the moment Ctrl-G opens the editor — confirmed by searching
  a 4000-byte window around the actual spawn call (`kte()`/`Dmt()`) for any
  hook dispatch; there is none. `Stop` is the only lever available, and it
  runs asynchronously and cross-process relative to Ctrl-G.
- **A CLAUDE.md instruction**: can't reach this layer at all — CLAUDE.md
  only shapes what gets written into the conversation by the model, not
  Claude Code's own internal editor-spawn implementation.

**What *is* usable, deterministically, no heuristics:** the hook's own
stdin payload already includes a `cwd` field (confirmed via `Kf()`, the
shared base builder for every hook event's payload — `{session_id, transcript_path,
cwd: Ht(), ...}`), and separately, the spawned nvim's own `getcwd()`
already equals that same project directory, because `spawnSync` never
overrides `cwd`, so the child inherits it unchanged. Both sides can hash
that shared, already-available string identically and agree on a filename
— no PID lookup, no env var, no content matching:

- Write side: `/tmp/claude_last_response-<hash>.md`, where
  `<hash> = sha256(cwd)[:16]`, `cwd` read directly from the hook's own
  stdin JSON.
- Read side: same hash of nvim's own `getcwd()`.

This eliminates **cross-project** collisions entirely and for free. It does
**not** eliminate same-project, multi-session collisions — there is no
signal anywhere (checked exhaustively above) that lets nvim tell two
same-directory sessions apart. That residual case was accepted as a known,
rare, and self-detecting limitation (the native `# … (earlier output
truncated)` marker stays visible in the buffer when the wrong/no file
lands, so a stale read is never silently trusted) — not solved.

## Drafted code (written this session, now removed with the revert)

**`claude-setup/global/hooks/inject-last-response.sh`** — the per-project
version, last state before deletion:

```bash
#!/usr/bin/env bash
# Stop hook: dumps the full text of Claude's most recent reply to
# /tmp/claude_last_response-<hash>.md, untruncated, so nvim's
# ClaudeInjectFullResponse() (basic-acmds.vim) can splice it into the
# Ctrl-G editor buffer in place of Claude Code's own inline quote, which
# truncates to its last 50 lines.
#
# <hash> is sha256(cwd)[:16], where cwd is the project directory Claude
# Code reports in the hook's own stdin payload. This scopes the file per
# project rather than machine-wide: two Claude Code sessions in different
# directories never share a file. Two sessions in the *same* directory
# still share one file and can clobber each other -- Claude Code passes no
# session identifier to the spawned $EDITOR process (confirmed by reading
# the installed binary's spawnSync call), so per-session scoping isn't
# reachable without a heuristic. Accepted as a known, self-detecting
# limitation (the native "(earlier output truncated)" marker stays visible
# when the wrong/no file lands).
#
# Silent on any failure (bad/missing transcript, no text content) so a
# hook bug never blocks or spams a session; on failure it also removes any
# stale file so a later Ctrl-G doesn't inject an unrelated old response.

python3 -c "$(cat <<'PYEOF'
import hashlib
import json
import os
import sys

OUT = None


def bail():
    if OUT:
        try:
            os.remove(OUT)
        except OSError:
            pass
    sys.exit(0)


try:
    hook_input = json.load(sys.stdin)
    transcript_path = hook_input.get("transcript_path")
    cwd = hook_input.get("cwd")
    if not transcript_path or not os.path.isfile(transcript_path) or not cwd:
        bail()
    OUT = "/tmp/claude_last_response-" + hashlib.sha256(cwd.encode()).hexdigest()[:16] + ".md"
    with open(transcript_path, encoding="utf-8") as f:
        entries = [json.loads(line) for line in f if line.strip()]
except Exception:
    bail()

# A single reply can span several trailing "assistant" transcript entries
# when tool calls are interleaved with prose, so the last entry alone can
# miss earlier text blocks belonging to the same reply. Walk backward and
# collect every assistant entry up to the previous non-assistant one.
tail = []
for entry in reversed(entries):
    if entry.get("type") != "assistant" or entry.get("isSidechain"):
        break
    tail.append(entry)
tail.reverse()

texts = []
for entry in tail:
    for block in entry.get("message", {}).get("content") or []:
        if block.get("type") == "text" and block.get("text", "").strip():
            texts.append(block["text"])

if not texts:
    bail()

response = "\n\n".join(texts)
lines = ["# " + line if line else "#" for line in response.split("\n")]

try:
    with open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
except OSError:
    pass
PYEOF
)"
```

Registration removed from both `claude-setup/global/settings.json` and the
live `~/.claude/settings.json` — was:

```json
"Stop": [
  { "hooks": [ { "type": "command", "command": "bash ${HOME}/.claude/hooks/inject-last-response.sh", "timeout": 10 } ] }
]
```

**`basic-acmds.vim`** (this repo) — the nvim side was never updated to the
per-project scheme before the revert (still had the global path when
removed). The one-line change that was pending, never applied:

```vim
function! ClaudeInjectFullResponse()
  let l:rfile = '/tmp/claude_last_response-' . sha256(getcwd())[0:15] . '.md'
  if !filereadable(l:rfile) | return | endif

  let l:header_line = search('^# .*Claude.s last response', 'nw')
  let l:footer_line = search('^# .*Write your reply below', 'nw')
  if l:header_line == 0 || l:footer_line == 0 | return | endif

  let l:footer_text = getline(l:footer_line)
  let l:header_text = getline(l:header_line)
  let l:lines = readfile(l:rfile)

  execute l:header_line . ',' . l:footer_line . 'delete _'
  call append(l:header_line - 1, [l:header_text] + l:lines + [l:footer_text])

  call cursor(l:header_line + len(l:lines) + 2, 1)
endfunction

autocmd BufReadPost /tmp/claude-prompt-*.md,/tmp/**/claude-prompt-*.md call ClaudeInjectFullResponse()
```

(Uses Vim's built-in `sha256()` — no shelling out needed on the read side.)

## To pick this back up

1. Re-add the vim function + autocmd above to `basic-acmds.vim`.
2. Re-create `claude-setup/global/hooks/inject-last-response.sh` with the
   script above, `chmod +x`, symlink from `~/.claude/hooks/` (or let the
   install/sync tooling do it).
3. Re-add the `Stop` hook registration to `claude-setup/global/settings.json`
   and sync/mirror it into the live `~/.claude/settings.json`.
4. Verify `/config` still has "Show last response in external editor" on.
5. Test end-to-end the same way this session did: replay the hook script
   against a real transcript's `.jsonl` prefix to confirm it writes the
   right file, then a headless-nvim reproduction
   (`nvim --headless -c "edit <synthetic-prompt-file>" -c "write! <out>" -c "qa!"`)
   to confirm the splice lands correctly, *before* trusting a live Ctrl-G
   test.
