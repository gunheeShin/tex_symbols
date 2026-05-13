#!/usr/bin/env bash
# =============================================================
# watch-preamble.sh
#
# Bash port of watch-preamble.ps1 for Linux.
# Watches include/**/*.tex and auto-rebuilds preamble.sty
# via build-preamble.sh.
#
# The MathJax Preamble Manager plugin (Obsidian) detects the
# preamble.sty change and hot-reloads -- no Ctrl+R needed.
#
# Every event and build result is also appended to
#   tex/obsidian/watch-preamble.log
#
# Requires: inotify-tools
#   sudo apt install inotify-tools
#
# Usage (from anywhere):
#   bash tex/obsidian/watch-preamble.sh
# =============================================================
set -uo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tex_dir="$(dirname "$script_dir")"
watch_dir="$tex_dir/include"
build_script="$script_dir/build-preamble.sh"
log_file="$script_dir/watch-preamble.log"

if ! command -v inotifywait >/dev/null 2>&1; then
  echo "Error: inotifywait not found." >&2
  echo "Install with: sudo apt install inotify-tools" >&2
  exit 1
fi

[[ -d "$watch_dir" ]] || { echo "Cannot find $watch_dir" >&2; exit 1; }
[[ -x "$build_script" ]] || chmod +x "$build_script"

# log_line: print to stdout AND append to log file, with timestamp prefix.
log_line() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" | tee -a "$log_file"
}

echo "Watching $watch_dir"
echo "  -> rebuilds preamble.sty on .tex change (hot-reload in Obsidian)"
echo "  Log : $log_file"
echo "  Press Ctrl+C to stop."

log_line "===== watcher started (pid $$) ====="

trap 'log_line "===== watcher stopped ====="' EXIT

# Debounce: skip events fired within 500ms of the last build
last_build=0
debounce_ms=500

while IFS=' ' read -r event path; do
  [[ "$path" == *.tex ]] || continue

  now_ms=$(date +%s%3N)
  if (( now_ms - last_build < debounce_ms )); then
    continue
  fi
  last_build=$now_ms

  rel="${path#"$watch_dir/"}"
  log_line "$event: $rel"

  sleep 0.1
  if build_out=$(bash "$build_script" 2>&1); then
    while IFS= read -r line; do log_line "  $line"; done <<<"$build_out"
  else
    log_line "  BUILD FAILED:"
    while IFS= read -r line; do log_line "  $line"; done <<<"$build_out"
  fi
done < <(inotifywait -m -r -q -e modify,create,delete,move --format '%e %w%f' "$watch_dir")
