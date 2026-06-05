import urllib.request
import json

urls = [
    "https://barishalnews.com/wp-json/wp/v2/posts?per_page=1",
    "https://www.barishaltimes.com/wp-json/wp/v2/posts?per_page=1",
    "https://barishalcrimenews.com/wp-json/wp/v2/posts?per_page=1"
]

for url in urls:
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=10) as response:
            data = json.loads(response.read().decode())
            print(f"SUCCESS {url}: Got {len(data)} posts")
    except Exception as e:
        print(f"FAILED {url}: {e}")

# Check RSS as well
rss_urls = [
    "https://barishalnews.com/feed/",
    "https://www.barishaltimes.com/feed/",
    "https://barishalcrimenews.com/feed/"
]

for url in rss_urls:
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=10) as response:
            print(f"RSS SUCCESS {url}: Status {response.status}")
    except Exception as e:
        print(f"RSS FAILED {url}: {e}")
