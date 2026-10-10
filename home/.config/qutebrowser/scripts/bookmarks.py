# Pinterest!/usr/bin/env python3
import os, html
from pathlib import Path

home = Path.home()
src = home / ".config/qutebrowser/bookmarks/urls"
colors = (home / ".cache/wal/colors").read_text().split()
bg, fg, dim = colors[0], colors[15], colors[8]

rows = ""
for line in src.read_text().splitlines():
    if not line.strip():
        continue
    url, _, title = line.partition(" ")
    rows += (f'<a href="{html.escape(url)}"><span>{html.escape(title or url)}</span>'
             f'<span class="u">{html.escape(url)}</span></a>\n')

page = f"""<!DOCTYPE html><html><head><meta charset="utf-8"><title>Bookmarks</title>
<style>
body {{ background:{bg}; color:{fg}; font-family:monospace; font-size:1.6rem; margin:2em; }}
h1 {{ color:{dim}; font-weight:normal; }}
a {{ display:flex; justify-content:space-between; padding:.5em; color:{fg}; text-decoration:none; }}
a:hover {{ background:{fg}; color:{bg}; }}
.u {{ color:{dim}; }}
</style></head><body><h1>Bookmarks</h1>
{rows}</body></html>"""

out = home / ".cache/qute-bookmarks.html"
out.write_text(page)
if "QUTE_FIFO" in os.environ:
    with open(os.environ["QUTE_FIFO"], "w") as f:
        f.write(f"open -t file://{out}\n")
