#!/usr/bin/env bash
# Compact Codeberg contribution graph for the terminal.
# One small square per day, one column per week. Colors follow pywal.

USER_NAME="${CODEBERG_USER:-offluencer}"
WEEKS="${COMMITGRAPH_WEEKS:-26}"
CELL="■"   # try ▪ for smaller squares with wider gaps
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/codeberg-heatmap.json"
MAX_AGE=3600
URL="https://codeberg.org/api/v1/users/$USER_NAME/heatmap"

refresh() {
  curl -fsS --max-time 5 "$URL" -o "$CACHE.tmp" && mv "$CACHE.tmp" "$CACHE"
}

mkdir -p "$(dirname "$CACHE")"
if [ ! -s "$CACHE" ]; then
  refresh 2>/dev/null || exit 0
elif [ $(( $(date +%s) - $(stat -c %Y "$CACHE") )) -gt "$MAX_AGE" ]; then
  (refresh >/dev/null 2>&1 &)
fi

cols=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}
max=$(( cols - 26 ))
[ "$WEEKS" -gt "$max" ] && WEEKS=$max
[ "$WEEKS" -lt 4 ] && exit 0

z=$(date +%z)
off=$(( 10#${z:1:2} * 3600 + 10#${z:3:2} * 60 ))
[ "${z:0:1}" = "-" ] && off=$(( -off ))

awk -v weeks="$WEEKS" -v cell="$CELL" -v now="$(date +%s)" -v off="$off" -v user="$USER_NAME" '
function level(n) { return n == 0 ? 8 : n <= 2 ? 4 : n <= 5 ? 6 : 15 }
function fg(p) { return p < 8 ? 30 + p : 90 + p - 8 }
BEGIN { RS = "}" }
{
  if (match($0, /"timestamp":[0-9]+/)) {
    t = substr($0, RSTART + 12, RLENGTH - 12)
    if (match($0, /"contributions":[0-9]+/)) {
      c = substr($0, RSTART + 16, RLENGTH - 16)
      cnt[int((t + off) / 86400)] += c
    }
  }
}
END {
  today = int((now + off) / 86400)
  start = today - (today + 3) % 7 - (weeks - 1) * 7   # Monday, weeks ago
  total = 0; days = 0
  for (d = start; d <= today; d++) { total += cnt[d]; if (cnt[d] > 0) days++ }

  side[1] = sprintf("\033[1m%s\033[0m", user)
  side[2] = sprintf("\033[90m%d contributions\033[0m", total)
  side[3] = sprintf("\033[90m%d active days\033[0m", days)
  side[5] = sprintf("\033[90mless \033[%dm%s\033[%dm%s\033[%dm%s\033[%dm%s\033[90m more\033[0m",
                    fg(8), cell, fg(4), cell, fg(6), cell, fg(15), cell)

  for (r = 0; r < 7; r++) {
    line = "  "
    for (w = 0; w < weeks; w++) {
      d = start + w * 7 + r
      if (d > today) { line = line " "; continue }
      line = line sprintf("\033[%dm%s", fg(level(cnt[d] + 0)), cell)
    }
    printf "%s\033[0m   %s\n", line, side[r]
  }
}' "$CACHE"
