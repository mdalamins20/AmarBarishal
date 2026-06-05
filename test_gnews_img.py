import urllib.request
import urllib.parse
from bs4 import BeautifulSoup
import re

url = "https://news.google.com/rss/articles/CBMiaEFVX3lxTFBvcUZDYkxsOEY3LXJUT2pzd2tnVUZnTjZnSXZILWZGTG1fWUgtSnU5cnRWREYtVmpzVmpNNm90cXhRcU9hVl9sQ0E3bDhBZ0VUbEVyQ0F5RERwcVRTX0hUcW4yRTRxLVlW0gF2QVVfeXFMTkhGZkw2VUZZTHI4eVA5SWlDN01vSTIxaDNKcmVxd0RQSGE1aTI5b2E2X2hKUVpiMW5PVlBiQVBDWHJDVUVOVWUtTEdTUm1FUTJDem40WGJMLVhYZzRmaXVwUFBGUlRxTGxHV2luX0szVS0tRVlGdw?oc=5"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'})
try:
    with urllib.request.urlopen(req, timeout=10) as response:
        content = response.read()
        soup = BeautifulSoup(content, 'html.parser')
        
        # Google News redirects using javascript or meta refresh sometimes, OR directly gives the page.
        # Let's check if there's a meta refresh or an og:image
        og_image = soup.find('meta', property='og:image')
        if og_image:
            print("Found image directly:", og_image.get('content'))
        else:
            # Maybe it's a redirect page
            print("No image found on this page. Page title:", soup.title.string if soup.title else "No title")
            print("Meta tags:", soup.find_all('meta'))
except Exception as e:
    print(f"Error: {e}")
