#!/data/data/com.termux/files/usr/bin/bash
# smoke-test.sh — verify a claude binary launches on this device.
# Usage: smoke-test.sh <binary> <versions-dir>
# Returns 0 = healthy, 1 = crashes/hangs.
set -u
BIN="$1"
VDIR="${2:-/tmp}"
ST_HOME="$VDIR/.smoke-home"
ST_ERR="$VDIR/.smoke-stderr"

[ -s "$BIN" ] || exit 1
rm -rf "$ST_HOME"; mkdir -p "$ST_HOME/.claude"
HOME="$ST_HOME" LD_PRELOAD= timeout -s KILL 25 "$BIN" --init-only </dev/null >/dev/null 2>"$ST_ERR"
rc=$?
rm -rf "$ST_HOME"
if [ "$rc" -gt 128 ] && [ "$rc" -le 159 ]; then rm -f "$ST_ERR"; exit 1; fi
if [ "$rc" -eq 124 ] || [ "$rc" -eq 126 ] || [ "$rc" -eq 127 ]; then rm -f "$ST_ERR"; exit 1; fi
if grep -qE 'Bad system call|oh no: Bun has crashed|panic\(|bun\.report' "$ST_ERR" 2>/dev/null; then
  rm -f "$ST_ERR"; exit 1
fi
rm -f "$ST_ERR"
exit 0
