import firebase_admin
from firebase_admin import credentials, firestore
import requests
from bs4 import BeautifulSoup
import os
from datetime import datetime
import re

# List of news sources (RSS feeds)
SOURCES = [
    {"name": "বরিশাল নিউজ", "url": "https://barishalnews.com/feed/"},
    {"name": "বরিশাল টাইমস", "url": "https://www.barishaltimes.com/feed/"},
    {"name": "বরিশাল ক্রাইম নিউজ", "url": "https://barishalcrimenews.com/feed/"},
    # JagoNews doesn't have a specific RSS feed for Barishal category, so we will scrape their HTML page for Barishal
    {"name": "জাগো নিউজ ২৪", "url": "https://www.jagonews24.com/bangladesh/barisal/barisal", "type": "html"}
]

def clean_html(raw_html):
    if not raw_html: return ""
    cleanr = re.compile('<.*?>')
    cleantext = re.sub(cleanr, '', str(raw_html))
    return cleantext.strip()

def extract_image_from_content(content):
    if not content: return ""
    soup = BeautifulSoup(content, 'html.parser')
    img = soup.find('img')
    if img and img.get('src'):
        return img.get('src')
    return ""

def fetch_rss_news(source):
    news_items = []
    try:
        headers = {'User-Agent': 'Mozilla/5.0'}
        response = requests.get(source['url'], headers=headers, timeout=15)
        soup = BeautifulSoup(response.content, 'xml')
        items = soup.find_all('item')
        
        for item in items[:10]: # Get top 10 from each
            title = item.title.text if item.title else "শিরোনাম নেই"
            link = item.link.text if item.link else ""
            pubDate = item.pubDate.text if item.pubDate else ""
            
            # Try to find image
            image_url = ""
            # Check content:encoded first
            content = item.find('content:encoded')
            if content:
                image_url = extract_image_from_content(content.text)
            
            if not image_url and item.description:
                image_url = extract_image_from_content(item.description.text)
                
            excerpt = clean_html(item.description.text if item.description else "")
            # Truncate excerpt
            if len(excerpt) > 150:
                excerpt = excerpt[:147] + "..."
                
            news_items.append({
                "name": title,
                "type": "news",
                "source": source['name'],
                "url": link,
                "date": pubDate,
                "image_url": image_url,
                "excerpt": excerpt,
                "timestamp": firestore.SERVER_TIMESTAMP
            })
    except Exception as e:
        print(f"Error fetching {source['name']}: {e}")
    return news_items

def fetch_html_news(source):
    news_items = []
    try:
        headers = {'User-Agent': 'Mozilla/5.0'}
        response = requests.get(source['url'], headers=headers, timeout=15)
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # JagoNews specific parsing (heuristic)
        articles = soup.find_all('div', class_='col-sm-6') # Often used for grid items
        if not articles:
            articles = soup.find_all('div', class_='row')
            
        count = 0
        for article in articles:
            a_tag = article.find('a')
            if not a_tag or not a_tag.get('href'): continue
            
            link = a_tag.get('href')
            if not link.startswith('http'):
                link = "https://www.jagonews24.com" + link
                
            img_tag = article.find('img')
            image_url = img_tag.get('src') if img_tag else ""
            
            title_tag = article.find(['h2', 'h3', 'h4'])
            if not title_tag:
                img_alt = img_tag.get('alt') if img_tag else ""
                title = img_alt if img_alt else a_tag.text.strip()
            else:
                title = title_tag.text.strip()
                
            if not title or len(title) < 10: continue
            
            news_items.append({
                "name": title,
                "type": "news",
                "source": source['name'],
                "url": link,
                "date": str(datetime.now().date()), # JagoNews list might not have date easily
                "image_url": image_url,
                "excerpt": "বিস্তারিত জানতে লিংকে ক্লিক করুন।",
                "timestamp": firestore.SERVER_TIMESTAMP
            })
            count += 1
            if count >= 10: break
    except Exception as e:
        print(f"Error fetching HTML {source['name']}: {e}")
    return news_items

def upload_news():
    try:
        cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
        firebase_admin.initialize_app(cred)
    except ValueError:
        pass
        
    db = firestore.client()
    collection_ref = db.collection('categories').document('newspaper').collection('items')
    
    # Optional: Delete old news to keep it fresh, or just overwrite/append.
    # We will delete old news to keep it daily fresh and save storage.
    print("Deleting old news...")
    docs = collection_ref.stream()
    for doc in docs:
        doc.reference.delete()
        
    all_news = []
    for source in SOURCES:
        print(f"Fetching news from {source['name']}...")
        if source.get('type') == 'html':
            news = fetch_html_news(source)
        else:
            news = fetch_rss_news(source)
        all_news.extend(news)
        print(f"Found {len(news)} items from {source['name']}.")
        
    print("Uploading to Firestore...")
    for item in all_news:
        collection_ref.add(item)
    print("News upload complete!")

if __name__ == "__main__":
    upload_news()
