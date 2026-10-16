#!/usr/bin/env bash
# Compact GitHub contribution graph for the terminal.
# One small square per day, one column per week. Empty days follow pywal, active days are green.

USER_NAME="${GITHUB_USER:-offluencer-com}"
WEEKS="${COMMITGRAPH_WEEKS:-26}"
CELL="■"   # try ▪ for smaller squares with wider gaps
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/github-heatmap.txt"
MAX_AGE=3600

# Uses the gh login, so private contributions count too. Cache holds "<day number> <count>" lines.
QUERY='query($login: String!) { user(login: $login) { contributionsCollection { contributionCalendar {
  weeks { contributionDays { date contributionCount } } } } } }'

refresh() {
  gh api graphql -f query="$QUERY" -f login="$USER_NAME" --jq '
    .data.user.contributionsCollection.contributionCalendar.weeks[].contributionDays[]
    | select(.contributionCount > 0)
    | "\((.date + "T00:00:00Z" | fromdateiso8601) / 86400) \(.contributionCount)"' > "$CACHE.tmp" \
    && mv "$CACHE.tmp" "$CACHE"
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
# Empty days use the pywal grey (color 8), active days use fixed greens.
function col(n) {
  if (n == 0) return "\033[90m"
  if (n <= 2) return "\033[38;2;14;68;41m"
  if (n <= 4) return "\033[38;2;0;109;50m"
  if (n <= 7) return "\033[38;2;38;166;65m"
  return "\033[38;2;57;211;83m"
}
{ cnt[$1] += $2 }
END {
  today = int((now + off) / 86400)
  start = today - (today + 3) % 7 - (weeks - 1) * 7   # Monday, weeks ago
  total = 0; days = 0
  for (d = start; d <= today; d++) { total += cnt[d]; if (cnt[d] > 0) days++ }

  side[1] = sprintf("\033[1m%s\033[0m", user)
  side[2] = sprintf("\033[90m%d contributions\033[0m", total)
  side[3] = sprintf("\033[90m%d active days\033[0m", days)
  side[5] = sprintf("\033[90mless %s%s%s%s%s%s%s%s%s%s\033[90m more\033[0m",
                    col(0), cell, col(1), cell, col(3), cell, col(5), cell, col(8), cell)

  for (r = 0; r < 7; r++) {
    line = "  "
    for (w = 0; w < weeks; w++) {
      d = start + w * 7 + r
      if (d > today) { line = line " "; continue }
      line = line col(cnt[d] + 0) cell
    }
    printf "%s\033[0m   %s\n", line, side[r]
  }
}' "$CACHE"
