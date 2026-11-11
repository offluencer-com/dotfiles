#!/usr/bin/env bash
# Writing stats for the terminal greeting. commitgraph.sh prints them beside the GitHub graph.
#
# How it works: it counts every word in your writing folder and saves one line per day
# ("2026-11-11 19135") in a log. Words written today = today's total minus the last
# total from an earlier day. So nothing to log by hand: just write and save.
#
#   writingstats.sh           print the panel
#   writingstats.sh --record  only update the log (nvim calls this when you save)

WRITING_DIR="${WRITING_DIR:-$HOME/Documents/Writing}"   # counts toward today/week
GOAL_DIR="${WRITING_GOAL_DIR:-$WRITING_DIR/Metanoja/chapters}"  # counts toward the goal
GOAL_NAME="${WRITING_GOAL_NAME:-Metanoja}"
GOAL="${WRITING_GOAL:-150000}"
DAILY_TARGET="${WRITING_DAILY:-500}"   # a day with this many words gets the brightest square

DATA="${XDG_DATA_HOME:-$HOME/.local/share}/writingstats"
LOG="$DATA/log"         # "<date> <total words>" per day
GOAL_FILE="$DATA/goal"  # last word count of the goal folder

[ -d "$WRITING_DIR" ] || exit 0
mkdir -p "$DATA"

# Total words in all .tex and .md files of a folder (hidden folders and templates skipped).
count_words() {
  find "$1" -not -path '*/.*' -not -path '*/templates/*' \( -name '*.tex' -o -name '*.md' \) \
    -exec texcount -1 -sum -q {} + 2>/dev/null | awk '{ s += $1 } END { print s + 0 }'
}

# Counting takes about half a second, so only recount when a file changed since the last count.
today=$(date +%F)
if [ ! -s "$LOG" ] || [ -n "$(find "$WRITING_DIR" -newer "$LOG" \( -name '*.tex' -o -name '*.md' \) -print -quit)" ]; then
  total=$(count_words "$WRITING_DIR")
  goal_words=$(count_words "$GOAL_DIR")
  echo "$goal_words" > "$GOAL_FILE"
  # Replace today's line (if any) with the new total.
  { grep -v "^$today " "$LOG" 2>/dev/null; echo "$today $total"; } > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
fi

[ "$1" = "--record" ] && exit 0

awk -v today="$today" -v now="$(date +%s)" -v goal="$GOAL" -v goal_name="$GOAL_NAME" \
    -v goal_words="$(cat "$GOAL_FILE" 2>/dev/null || echo 0)" -v target="$DAILY_TARGET" '
function dim(s)  { return "\033[90m" s "\033[0m" }
function bold(s) { return "\033[1m" s "\033[0m" }
function green(s){ return "\033[38;2;57;211;83m" s "\033[0m" }
# 12345 -> "12 345"
function num(n,   s, out) {
  s = sprintf("%d", n); out = ""
  while (length(s) > 3) { out = " " substr(s, length(s) - 2) out; s = substr(s, 1, length(s) - 3) }
  return s out
}
# Same greens as the GitHub graph, scaled to the daily target.
function cell(n) {
  if (n <= 0)            return "\033[90m■"
  if (n < target * 0.25) return "\033[38;2;14;68;41m■"
  if (n < target * 0.5)  return "\033[38;2;0;109;50m■"
  if (n < target)        return "\033[38;2;38;166;65m■"
  return "\033[38;2;57;211;83m■"
}
# Date "YYYY-MM-DD" -> day number (days since 1970), so days can be subtracted.
function daynum(d,   y, m, a) {
  y = substr(d, 1, 4) + 0; m = substr(d, 6, 2) + 0; a = substr(d, 9, 2) + 0
  if (m <= 2) { y--; m += 12 }
  return int(365.25 * y) + int(30.6001 * (m + 1)) + a - 719606
}

# Words written on a day = its total minus the previous logged total (never below 0).
{ day = daynum($1); words[day] = (NR > 1 && $2 > prev) ? $2 - prev : 0; prev = $2
  if (NR == 1) first = day }

END {
  t = daynum(today)
  monday = t - (t + 3) % 7

  week = 0
  for (d = monday; d <= t; d++) week += words[d]

  all = 0
  for (d in words) all += words[d]
  weeks = (t - first + 1) / 7; if (weeks < 1) weeks = 1

  pct = goal > 0 ? goal_words * 100 / goal : 0
  bar_len = 10; filled = int(pct * bar_len / 100); if (filled < 1 && goal_words > 0) filled = 1; if (filled > bar_len) filled = bar_len
  bar = ""
  for (i = 0; i < bar_len; i++) bar = bar (i < filled ? "\033[38;2;57;211;83m━" : "\033[90m━")

  squares = ""
  for (d = monday; d < monday + 7; d++) squares = squares (d > t ? " " : cell(words[d]))

  # Exactly 7 lines, one per row of the GitHub graph, so commitgraph.sh can print them beside it.
  # "Tail" uses terminal color 3, so it follows the pywal theme of the wallpaper.
  print bold("󱐍 Poet! Pick up the ") "\033[1;33mTail\033[0m" bold("!")
  printf "%s%s  %s\033[0m\n", dim("today     "), (words[t] > 0 ? bold(sprintf("%-6s", num(words[t]))) : dim(sprintf("%-6s", 0))), squares
  printf "%s%s\n", dim("this week "), num(week)
  printf "%s%s\n", dim("avg week  "), num(all / weeks)
  printf "%s%s\033[0m %s\n", dim(sprintf("%-10s", goal_name)), bar, bold(sprintf("%.1f%%", pct))
  printf "%s\n", dim(sprintf("%-10s", "") num(goal_words) " / " num(goal))
  print (words[t] <= 0 ? dim("✎ the page is blank today") : "")
}' "$LOG"
