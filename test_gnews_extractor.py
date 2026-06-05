import requests
from bs4 import BeautifulSoup
import re

real_ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
# Example Google News link for Prothom Alo Barishal
url = "https://news.google.com/rss/articles/CBMiJWh0dHBzOi8vd3d3LnByb3Rob21hbG8uY29tL2JhbmdsYWRlc2gvYmFyaXNoYWwvYTEybG1zMmRsN9IBAA?oc=5"

page_req = requests.get(url, headers={'User-Agent': real_ua}, timeout=10)
print("Status:", page_req.status_code)
page_soup = BeautifulSoup(page_req.content, 'html.parser')

final_url = url
noscript = page_soup.find('noscript')
print("Noscript:", noscript)
if noscript:
    meta = noscript.find('meta')
    print("Meta:", meta)
    if meta and 'url=' in meta.get('content', '').lower():
        content_str = meta.get('content')
        match = re.search(r'url=(.*)', content_str, re.IGNORECASE)
        if match:
            final_url = match.group(1).strip()
            
c_wiz = page_soup.find('c-wiz')
print("C-wiz:", bool(c_wiz))
if c_wiz:
    a_tag = page_soup.find('a')
    print("A tag in c-wiz:", a_tag)
    if a_tag and a_tag.get('href'):
        final_url = a_tag.get('href')

print("FINAL URL:", final_url)
