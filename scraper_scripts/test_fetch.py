import sys
import codecs
sys.stdout = codecs.getwriter("utf-8")(sys.stdout.detach())

from fetch_news import SOURCES, fetch_rss_news, fetch_html_news

for source in SOURCES:
    if source.get('type') == 'html':
        news = fetch_html_news(source)
    else:
        news = fetch_rss_news(source)
    print(f"Source: {source['url']} -> Found {len(news)} items")
