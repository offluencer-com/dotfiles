#!/usr/bin/env python3

import datetime
import email.utils
import html
import json
import re
import urllib.request

BASE = "https://www.banjaluka.com"
CATEGORY_ID = 91  # Najave
PER_PAGE = 15

HEADERS = {"User-Agent": "Mozilla/5.0"}


def fetch_json(url):
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=15) as resp:
        return json.loads(resp.read().decode("utf-8"))


api_url = (
    f"{BASE}/wp-json/wp/v2/posts?"
    f"categories={CATEGORY_ID}&per_page={PER_PAGE}&orderby=date&order=desc"
    f"&_fields=id,date_gmt,link,title,content"
)

posts = fetch_json(api_url)


def clean_content(raw_html):
    # Drop images, embeds, scripts and comments - not useful in a terminal reader.
    raw_html = re.sub(r"<!--.*?-->", "", raw_html, flags=re.S)
    raw_html = re.sub(r"<script.*?</script>", "", raw_html, flags=re.S | re.I)
    raw_html = re.sub(r"<style.*?</style>", "", raw_html, flags=re.S | re.I)
    raw_html = re.sub(r"<iframe.*?</iframe>", "", raw_html, flags=re.S | re.I)
    raw_html = re.sub(r"<figure[^>]*>.*?</figure>", "", raw_html, flags=re.S | re.I)
    raw_html = re.sub(r"<img[^>]*/?>", "", raw_html, flags=re.I)

    # Strip inline style/class attributes - clutter, not needed for rendering.
    raw_html = re.sub(r'\s+(style|class)="[^"]*"', "", raw_html, flags=re.I)

    return raw_html.strip()


def xml(s):
    return html.escape(s, quote=True)


print('<?xml version="1.0" encoding="UTF-8"?>')
print('<rss version="2.0">')
print("<channel>")
print("<title>Banjaluka.com — Najave</title>")
print(f"<link>{xml(BASE + '/najave/')}</link>")
print("<description>Najave dešavanja u Banjaluci</description>")

for post in posts:
    title = html.unescape(re.sub(r"<[^>]+>", "", post["title"]["rendered"])).strip()
    link = post["link"]

    dt = datetime.datetime.fromisoformat(post["date_gmt"]).replace(
        tzinfo=datetime.timezone.utc
    )
    pub_date = email.utils.format_datetime(dt)

    # html.unescape only decodes entities (&amp; &#8220; etc.) - it does not
    # touch literal < / > characters, so the real HTML tags stay intact.
    content = html.unescape(clean_content(post["content"]["rendered"]))

    print("<item>")
    print(f"<title>{xml(title)}</title>")
    print(f"<pubDate>{pub_date}</pubDate>")
    print(f"<link>{xml(link)}</link>")
    print(f'<guid isPermaLink="true">{xml(link)}</guid>')
    print(f"<description>{xml(content)}</description>")
    print("</item>")

print("</channel>")
print("</rss>")
