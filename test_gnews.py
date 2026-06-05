import urllib.request
import urllib.parse
import xml.etree.ElementTree as ET

query = "বরিশাল"
# To get news for a specific date, e.g., 2026-06-01
encoded_query = urllib.parse.quote(f"{query} after:2026-06-01 before:2026-06-03")
url = f"https://news.google.com/rss/search?q={encoded_query}&hl=bn&gl=BD&ceid=BD:bn"

req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
try:
    with urllib.request.urlopen(req, timeout=10) as response:
        content = response.read()
        root = ET.fromstring(content)
        items = root.findall('.//item')
        print(f"Found {len(items)} news items via Google News!")
        for item in items[:3]:
            title = item.findtext('title')
            link = item.findtext('link')
            pubDate = item.findtext('pubDate')
            source = item.findtext('source')
            print(f"- {title} | {source} | {pubDate}")
except Exception as e:
    print(f"Error: {e}")
