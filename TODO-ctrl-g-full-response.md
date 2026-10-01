# TODO: Ctrl-G full-response splice — remaining checks

Status as of 2026-10-01: implemented in `basic-acmds.vim`
(`ClaudeInjectFullResponse()` and its two helpers), entirely on the nvim side.
No Claude Code hook is involved.

## Background

Claude Code's Ctrl-G ("edit prompt in $EDITOR") file quotes Claude's last
response between `# ─── Claude's last response ───` and `# ─── Write your
reply below this line ───`. The quote is truncated natively to its last 50
lines, a compiled-in limit with no setting. The marker block exists only when
the `/config` toggle "Show last response in external editor"
(`externalEditorContext`) is on.

The first attempt (reverted 2026-08-04) used a `Stop` hook that dumped every
reply to a temp file, which nvim then read. It failed because nvim could not
tell which session spawned it. Claude Code passes no session id to the
editor's environment (re-confirmed on 2.1.286: `$CLAUDE_CODE_SESSION_ID` is
empty inside the Ctrl-G nvim), so two sessions in the same directory raced on
the same file.

## Current design

The session is identified through process ancestry and Claude Code's
per-process registry, which did not exist (or was not noticed) in August:

1. Every live Claude Code process writes `~/.claude/sessions/<pid>.json`,
   holding `sessionId`, `cwd` and `procStart` (the process start time in
   clock ticks, equal to field 22 of `/proc/<pid>/stat`).
2. nvim climbs its own parent chain through `/proc/<pid>/stat` until it finds
   a registry file whose `procStart` matches the live process. The walk climbs
   more than one level because Neovim 0.10+ runs Vimscript in an
   `nvim --embed` child of the TUI process. The `procStart` check is needed
   because the registry keeps files of dead sessions and pids get reused.
3. The transcript is `~/.claude/projects/*/<sessionId>.jsonl`. The splice
   takes the text blocks of the last assistant message that has any text,
   grouped by `message.id`. Mid-turn narration from earlier messages is
   excluded on purpose.

Claude Code flushes transcript entries a few seconds late (observed
2026-10-01). A Ctrl-G pressed right after a reply can therefore find the
transcript one message behind. The splice guards against this. It runs only
when the native quote's last non-empty line appears in the extracted
message's last non-empty line, and otherwise leaves the native quote in place.

The registry and the transcript format are both undocumented. If either
changes, the splice does nothing and the native "(earlier output truncated)"
marker stays visible.

## Remaining checks

- Live Ctrl-G test in a real session after a long reply. Headless tests have
  passed: the session lookup from a process launched under `claude`, and
  extraction of a 50-line, multi-message turn. Above all, confirm that the
  native quote is the raw markdown, line for line. If Claude Code renders or
  rewraps it, the staleness guard's last-line comparison never matches, and
  the splice silently never fires.
- Whether `/clear` and `--resume` update `sessionId` in the registry
  mid-process. If not, Ctrl-G after `/clear` would quote the pre-clear
  session's last message.
