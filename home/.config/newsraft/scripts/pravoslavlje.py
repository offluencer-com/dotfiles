#!/usr/bin/env python3

import datetime
import html
import re
import urllib.parse
import urllib.request

BASE = "https://pravoslavno.rs"

today = datetime.date.today()
pub_date = today.strftime("%a, %d %b %Y 00:00:00 +0200")
date = today.isoformat()
year = today.year
month = today.month
day = today.day

HEADERS = {"User-Agent": "Mozilla/5.0"}


def fetch(url):
    req = urllib.request.Request(url, headers=HEADERS)
    return urllib.request.urlopen(req, timeout=15).read().decode("utf-8", "replace")


def to_html_paragraphs(text):
    paras = [p.strip() for p in text.split("\n\n") if p.strip()]
    paras = [p.replace("\n", "<br>\n") for p in paras]
    return "\n".join(f"<p>{p}</p>" for p in paras)


# ---------- Kalendar: saint/feast title + fast status ----------

kalendar_url = (
    f"{BASE}/index.php?"
    + urllib.parse.urlencode({
        "q": "kalendar",
        "godina": year,
        "mesec": f"{month:02d}",
    })
)

kpage = fetch(kalendar_url)

row_pattern = re.compile(rf'<tr id="{day}" bgcolor=#ffe86e[^>]*>(.*?)</tr>', re.S | re.I)
row_match = row_pattern.search(kpage)

fast = False
saint_title = "Православни календар"

if row_match:
    row = row_match.group(1)
    fast = bool(re.search(r">\s*пост\s*<", row, re.I))

    # The day cell doesn't reliably carry a weekday class (it's only present
    # on Sundays), so just look for saint/feast links anywhere in the row.
    link_match = re.findall(
        r'<a\s+href="([^"]*q=kalenedar[^"]*)"[^>]*>(.*?)</a>',
        row, re.S | re.I
    )

    if link_match:
        # First link is the primary saint/feast for the day (matches the
        # short description pulled from the fff9cc row below).
        saint_title = html.unescape(re.sub(r"<[^>]+>", "", link_match[0][1])).strip()

# Short description of the day, from the row right after today's row.
kalendar_description = ""

if row_match:
    after_row = kpage[row_match.end():]

    description_match = re.search(
        r'<tr bgcolor=#fff9cc[^>]*>(.*?)</tr>',
        after_row,
        re.S | re.I
    )

    if description_match:
        kd = description_match.group(1)

        kd = re.sub(r'<a[^>]*>\s*<img[^>]*>\s*</a>', "", kd, flags=re.S | re.I)
        kd = re.split(r"<TROPAR:", kd, flags=re.I)[0]

        kd = re.sub(r"<br\s*/?>", "\n", kd, flags=re.I)
        kd = re.sub(r"</div>", "\n", kd, flags=re.I)
        kd = re.sub(r"<[^>]+>", "", kd)

        kd = html.unescape(kd)
        kd = kd.replace("\xa0", " ")
        kd = re.sub(r"[ \t]+", " ", kd)
        kd = re.sub(r"\n\s*\n+", "\n\n", kd)
        kalendar_description = kd.strip()

# ---------- Citanja: daily scripture readings ----------

citanja_url = (
    f"{BASE}/index.php?"
    + urllib.parse.urlencode({
        "datum": date,
        "q": "citanja",
    })
)

cpage = fetch(citanja_url)

pattern = re.compile(
    r'<div style="padding-top:12px;"><b>(.*?)</b></div>(.*?)(?=<div style="padding-top:12px;"><b>|</div><a name=teofan)',
    re.S
)

readings = []

for rtitle, body in pattern.findall(cpage):
    rtitle = html.unescape(re.sub(r"<[^>]+>", "", rtitle)).strip()

    body = re.sub(r"<br\s*/?>", "\n", body)
    body = re.sub(r"<[^>]+>", "", body)
    body = html.unescape(body)

    body = body.replace("\xa0", " ")
    body = re.sub(r"[ \t]+", " ", body)
    body = re.sub(r"\n\s*\n+", "\n\n", body)
    body = body.strip()

    if rtitle and body:
        readings.append((rtitle, body))

# ---------- Combine into a single RSS item ----------

fast_text = "ДА" if fast else "НЕ"

content = (
    f"<p><b>Датум:</b> {html.escape(today.strftime('%d.%m.%Y.'))}<br>\n"
    f"<b>Празник/светац:</b> {html.escape(saint_title)}<br>\n"
    f"<b>Пост:</b> {fast_text}</p>\n"
)

if kalendar_description:
    content += to_html_paragraphs(html.escape(kalendar_description)) + "\n"

for rtitle, body in readings:
    content += f"<p><b>{html.escape(rtitle)}</b></p>\n"
    content += to_html_paragraphs(html.escape(body)) + "\n"


def xml(s):
    return html.escape(s, quote=True)


print('<?xml version="1.0" encoding="UTF-8"?>')
print('<rss version="2.0">')
print("<channel>")
print("<title>Православље — дан</title>")
print(f"<link>{xml(kalendar_url)}</link>")
print("<description>Дневни календар и читања</description>")
print("<item>")
print(f"<title>{xml(f'{saint_title} — {date}')}</title>")
print(f"<pubDate>{pub_date}</pubDate>")
print(f"<link>{xml(citanja_url)}</link>")
print(f"<description>{xml(content)}</description>")
print("</item>")
print("</channel>")
print("</rss>")
