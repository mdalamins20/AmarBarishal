import requests
from bs4 import BeautifulSoup
import firebase_admin
from firebase_admin import credentials, firestore
import os

try:
    cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
    firebase_admin.initialize_app(cred)
except ValueError:
    pass

db = firestore.client()

def scrape_and_upload_sos():
    url = "https://bangladesh.gov.bd/pages/static-pages/69a55ba386514399668e4e89"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }
    
    response = requests.get(url, headers=headers, verify=True)
    soup = BeautifulSoup(response.text, 'html.parser')
    
    table = soup.find('table')
    if not table:
        print("Table not found!")
        return
        
    rows = table.find_all('tr')
    
    items_ref = db.collection('categories').document('sos').collection('items')
    
    # Optional: Clear existing sos data to avoid duplicates on multiple runs
    existing_docs = items_ref.stream()
    for doc in existing_docs:
        doc.reference.delete()
        
    count = 0
    for row in rows:
        cols = row.find_all('td')
        if len(cols) < 4:
            continue
            
        logo_url = ""
        img_tag = cols[0].find('img')
        if img_tag and 'src' in img_tag.attrs:
            logo_url = img_tag['src']
            if logo_url.startswith('/'):
                logo_url = "https://bangladesh.gov.bd" + logo_url
                
        link = ""
        a_tag = cols[1].find('a')
        if a_tag and 'href' in a_tag.attrs:
            link = a_tag['href']
            
        shortcode = cols[2].get_text(strip=True)
        description = cols[3].get_text(separator='\n', strip=True)
        
        if not shortcode and not description:
            continue
            
        data = {
            "logo": logo_url,
            "link": link,
            "shortcode": shortcode,
            "description": description,
            "order": count
        }
        
        items_ref.add(data)
        count += 1
        
    print(f"Successfully scraped and uploaded {count} SOS items.")

if __name__ == '__main__':
    scrape_and_upload_sos()
