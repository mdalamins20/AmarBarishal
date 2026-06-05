import requests
from bs4 import BeautifulSoup

url = "https://bn.wikipedia.org/wiki/%E0%A6%AC%E0%A6%BE%E0%A6%AC%E0%A7%81%E0%A6%97%E0%A6%9E%E0%A7%8D%E0%A6%9C_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE"
r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
soup = BeautifulSoup(r.content, 'html.parser')

content = soup.find('div', {'id': 'mw-content-text'})
parser_output = content.find('div', class_='mw-parser-output') if content else None

with open('wiki_debug.txt', 'w', encoding='utf-8') as f:
    if not parser_output:
        f.write("No parser_output found.\n")
    else:
        f.write(f"parser_output class: {parser_output.get('class')}\n")
        f.write(f"Number of direct children: {len(list(parser_output.children))}\n\n")
        for i, child in enumerate(parser_output.children):
            if child.name:
                f.write(f"[{i}] {child.name} - class: {child.get('class')}\n")
                if child.name == 'div':
                    f.write(f"    Inner tags: {[c.name for c in child.children if c.name]}\n")
            elif str(child).strip():
                f.write(f"[{i}] TEXT: {str(child)[:50]}\n")
