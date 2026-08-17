import requests
from bs4 import BeautifulSoup

url = "https://news.google.com/rss/search?q=%E0%A6%AC%E0%A6%B0%E0%A6%BF%E0%A6%B6%E0%A6%BE%E0%A6%B2&hl=bn&gl=BD&ceid=BD:bn"
res = requests.get(url)
soup = BeautifulSoup(res.content, 'xml')

items = soup.find_all('item')
count_with_img = 0
for item in items[:10]:
    desc = item.description.text if item.description else ""
    # Look for img tag
    if '<img' in desc:
        count_with_img += 1
        print("Found image in description")
    else:
        print("No image in description")

print(f"Total with img: {count_with_img}/{len(items[:10])}")
