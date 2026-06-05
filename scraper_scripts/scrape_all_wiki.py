import firebase_admin
from firebase_admin import credentials, firestore
import requests
from bs4 import BeautifulSoup
import re
import os

def init_firebase():
    try:
        cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
        firebase_admin.initialize_app(cred)
    except ValueError:
        pass
    return firestore.client()

def scrape_wikipedia(name, url, db):
    print(f"Scraping Wikipedia for {name}...")
    r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
    if r.status_code != 200:
        print(f"Failed to fetch {url}")
        return False
        
    soup = BeautifulSoup(r.content, 'html.parser')
    content = soup.find('div', {'id': 'mw-content-text'})
    
    sections = {}
    current_section = None
    img_url = ""
    
    # Try to find image in infobox
    infobox = soup.find('table', class_='infobox')
    if infobox:
        img_tag = infobox.find('img')
        if img_tag and img_tag.has_attr('src'):
            img_url = "https:" + img_tag['src']
            # Try to get higher res if possible by modifying thumbnail URL
            img_url = img_url.replace('/thumb', '')
            if img_url.count('/') > 0:
                img_url = '/'.join(img_url.split('/')[:-1])

    if content:
        parser_output = content.find('div', class_='mw-parser-output')
        if parser_output:
            elements = parser_output.find_all(['h2', 'h3', 'p', 'ul', 'ol'])
            
            for element in elements:
                if element.name in ['h2', 'h3']:
                    heading = element.get_text(strip=True).replace('[সম্পাদনা]', '')
                    # Remove any leading/trailing spaces or invisible characters
                    heading = heading.strip()
                    if heading in ['আরও দেখুন', 'তথ্যসূত্র', 'বহিঃসংযোগ', 'টীকা', 'গ্রন্থপঞ্জি', 'চিত্রশালা']:
                        current_section = None
                        continue
                    current_section = heading
                    sections[current_section] = []
                elif element.name in ['p', 'ul', 'ol']:
                    # Skip elements inside infoboxes, tables of contents, or navboxes
                    if element.find_parent(class_=['infobox', 'toc', 'navbox', 'metadata']):
                        continue
                        
                    text = element.get_text(separator=' ', strip=True)
                    if text:
                        text = re.sub(r'\[\s*[0-9a-zA-Zঅ-হ০-৯]+\s*\]', '', text)
                        text = re.sub(r'\s+', ' ', text).strip()
                        if current_section is None:
                            if "ভূমিকা" not in sections:
                                sections["ভূমিকা"] = []
                            sections["ভূমিকা"].append(text)
                        else:
                            sections[current_section].append(text)
                        
    final_data = {}
    for k, v in sections.items():
        if isinstance(v, list):
            joined = "\n\n".join(v)
            if joined.strip():
                final_data[k] = joined
        else:
            if v.strip():
                final_data[k] = v

    if img_url:
        final_data['image_url'] = img_url
        
    print(f"Found {len(final_data)} sections for {name}")

    collection_ref = db.collection('categories').document('upazila').collection('upazilas')
    existing = collection_ref.where('name', '==', name).get()
    
    if existing:
        doc_id = existing[0].id
        doc_ref = collection_ref.document(doc_id)
        doc_ref.set({
            "wiki_data": final_data
        }, merge=True)
        print(f"Successfully updated Firestore for {name}")
        return True
    else:
        print(f"Upazila '{name}' not found in Firestore!")
        return False

def main():
    db = init_firebase()
    
    upazilas = {
        "আগৈলঝাড়া উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%86%E0%A6%97%E0%A7%88%E0%A6%B2%E0%A6%9D%E0%A6%BE%E0%A6%A1%E0%A6%BC%E0%A6%BE_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "বাকেরগঞ্জ উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%AC%E0%A6%BE%E0%A6%95%E0%A7%87%E0%A6%B0%E0%A6%97%E0%A6%9E%E0%A7%8D%E0%A6%9C_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "বাবুগঞ্জ উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%AC%E0%A6%BE%E0%A6%AC%E0%A7%81%E0%A6%97%E0%A6%9E%E0%A7%8D%E0%A6%9C_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "বানারিপাড়া উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%AC%E0%A6%BE%E0%A6%A8%E0%A6%BE%E0%A6%B0%E0%A7%80%E0%A6%AA%E0%A6%BE%E0%A6%A1%E0%A6%BC%E0%A6%BE_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "গৌরনদী উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%97%E0%A7%8C%E0%A6%B0%E0%A6%A8%E0%A6%A6%E0%A7%80_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "হিজলা উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%B9%E0%A6%BF%E0%A6%9C%E0%A6%B2%E0%A6%BE_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "বরিশাল সদর উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%AC%E0%A6%B0%E0%A6%BF%E0%A6%B6%E0%A6%BE%E0%A6%B2_%E0%A6%B8%E0%A6%A6%E0%A6%B0_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "মেহেন্দিগঞ্জ উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%AE%E0%A7%87%E0%A6%B9%E0%A7%87%E0%A6%A8%E0%A7%8D%E0%A6%A6%E0%A6%BF%E0%A6%97%E0%A6%9E%E0%A7%8D%E0%A6%9C_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "মুলাদি উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%AE%E0%A7%81%E0%A6%B2%E0%A6%BE%E0%A6%A6%E0%A7%80_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE",
        "উজিরপুর উপজেলা": "https://bn.wikipedia.org/wiki/%E0%A6%89%E0%A6%9C%E0%A6%BF%E0%A6%B0%E0%A6%AA%E0%A7%81%E0%A6%B0_%E0%A6%89%E0%A6%AA%E0%A6%9C%E0%A7%87%E0%A6%B2%E0%A6%BE"
    }
    
    for name, url in upazilas.items():
        scrape_wikipedia(name, url, db)

if __name__ == "__main__":
    main()
