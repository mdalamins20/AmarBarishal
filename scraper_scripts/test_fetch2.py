import requests

urls = [
    "https://barishalnews.com/feed/",
    "https://www.barishaltimes.com/feed/",
    "https://barishalcrimenews.com/feed/",
    "https://www.jagonews24.com/bangladesh/barisal/barisal"
]

headers = {'User-Agent': 'Mozilla/5.0'}

for url in urls:
    try:
        res = requests.get(url, headers=headers, timeout=10)
        print(f"{url} -> {res.status_code}, Length: {len(res.content)}")
    except Exception as e:
        print(f"{url} -> Error: {e}")
