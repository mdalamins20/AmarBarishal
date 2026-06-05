import firebase_admin
from firebase_admin import credentials, firestore
import requests
from bs4 import BeautifulSoup
import os

def init_firebase():
    try:
        cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
        firebase_admin.initialize_app(cred)
    except ValueError:
        pass
    return firestore.client()

CATEGORY_MAP = {
    "Universities": ("university", "বিশ্ববিদ্যালয়", "school"),
    "Colleges": ("college", "কলেজ", "account_balance"),
    "Medical colleges": ("medical_college", "মেডিকেল কলেজ", "local_hospital"),
    "Engineering colleges": ("engineering_college", "ইঞ্জিনিয়ারিং কলেজ", "engineering"),
    "Polytechnic institutes": ("polytechnic", "পলিটেকনিক", "architecture"),
    "Higher secondary schools": ("higher_secondary", "উচ্চ মাধ্যমিক", "school"),
    "High schools": ("highSchool", "হাই স্কুল", "school"),
    "English medium schools": ("english_medium", "ইংলিশ মিডিয়াম", "school"),
    "Religious schools": ("madrasa", "মাদ্রাসা", "mosque"),
    "Technical schools": ("technical_school", "টেকনিক্যাল স্কুল", "build"),
    "Drama schools": ("drama_school", "ড্রামা স্কুল", "theater_comedy"),
    "Art schools": ("art_school", "আর্ট স্কুল", "palette"),
    "Training institutes": ("training_institute", "ট্রেনিং ইন্সটিটিউট", "model_training"),
    "Research institutions": ("research_institution", "রিসার্চ প্রতিষ্ঠান", "biotech"),
    "Special schools": ("special_school", "স্পেশাল স্কুল", "accessibility_new")
}

def main():
    db = init_firebase()
    url = "https://en.wikipedia.org/wiki/List_of_educational_institutions_in_Barisal_District"
    print(f"Fetching {url}")
    
    r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
    soup = BeautifulSoup(r.content, 'html.parser')
    
    # Check/Create Categories
    categories_ref = db.collection('categories')
    existing_categories = [doc.id for doc in categories_ref.stream()]
    
    for en_cat, (cat_id, bn_name, icon_name) in CATEGORY_MAP.items():
        if cat_id not in existing_categories:
            categories_ref.document(cat_id).set({
                'name': bn_name,
                'icon': icon_name,
            }, merge=True)
            print(f"Created/Updated Category: {bn_name} ({cat_id})")

    # Parsing the wiki content
    content = soup.find('div', class_='mw-parser-output')
    if not content:
        print("Could not find mw-parser-output")
        return
        
    current_category_id = None
    stats = {'added': 0, 'skipped': 0}
    
    for element in content.find_all(['h2', 'h3', 'ul', 'ol']):
        if element.name in ['h2', 'h3']:
            heading_text = element.get_text(strip=True).replace('[edit]', '').replace('[সম্পাদনা]', '')
            if heading_text in CATEGORY_MAP:
                current_category_id = CATEGORY_MAP[heading_text][0]
            else:
                # Could be "See also" or "References"
                if heading_text in ['See also', 'References', 'External links']:
                    current_category_id = None
        elif element.name in ['ul', 'ol'] and current_category_id:
            # Inside a valid category list
            list_items = element.find_all('li', recursive=False)
            
            for li in list_items:
                # Remove reference superscripts
                for sup in li.find_all('sup'):
                    sup.decompose()
                
                # Getting text up to comma or parenthesis
                text = li.get_text(strip=True)
                name = text.split(',')[0].split('(')[0].strip()
                
                if not name or len(name) < 3:
                    continue
                    
                collection_ref = db.collection('categories').document(current_category_id).collection('items')
                existing = collection_ref.where('name', '==', name).limit(1).get()
                
                if len(existing) > 0:
                    print(f"Skipping duplicate: {name} in {current_category_id}")
                    stats['skipped'] += 1
                else:
                    print(f"Adding: {name} to {current_category_id}")
                    collection_ref.add({
                        'name': name,
                        'source': 'Wikipedia',
                        'is_verified': True
                    })
                    stats['added'] += 1

    print(f"Done! Added: {stats['added']}, Skipped: {stats['skipped']}")

if __name__ == '__main__':
    main()
