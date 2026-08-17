import requests
from bs4 import BeautifulSoup
import firebase_admin
from firebase_admin import credentials, firestore
import os
import re

try:
    cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
    firebase_admin.initialize_app(cred)
except ValueError:
    pass

db = firestore.client()

def scrape_libraries():
    url = "https://barisal.gov.bd/pages/static-pages/6978958635ce18e1c0669ec9"
    try:
        response = requests.get(url, verify=True, timeout=15)
        response.raise_for_status()
    except Exception as e:
        print(f"Error fetching URL: {e}")
        return

    soup = BeautifulSoup(response.content, 'html.parser')
    table = soup.find('table')
    if not table:
        print("Table not found")
        return

    rows = table.find_all('tr')[1:] # Skip header
    library_ref = db.collection('categories').document('library').collection('items')
    
    count = 0
    for row in rows:
        cols = row.find_all('td')
        if len(cols) < 5:
            continue
            
        # Col 0: Sl No, Col 1: Name & Address, Col 2: Officer, Col 3: Mobile, Col 4: Established, Col 5: Books
        
        # Parse Name & Address
        raw_name_address = cols[1].get_text(separator='\n', strip=True)
        # Split by newline or comma. First part is name, rest is address.
        parts = [p.strip() for p in re.split(r'\n|,', raw_name_address) if p.strip()]
        
        name = parts[0] if len(parts) > 0 else ''
        address = ', '.join(parts[1:]) if len(parts) > 1 else ''
        
        # Parse other fields
        officer = cols[2].get_text(strip=True) if len(cols) > 2 else ''
        mobile = cols[3].get_text(strip=True) if len(cols) > 3 else ''
        established = cols[4].get_text(strip=True) if len(cols) > 4 else ''
        books = cols[5].get_text(strip=True) if len(cols) > 5 else ''
        
        # Clean mobile (remove anything that isn't digit or + or standard text)
        if mobile == '-' or mobile == 'নাই': mobile = ''
        
        data = {
            'name': name,
            'address': address,
            'officer': officer,
            'mobile': mobile,
            'established': established,
            'books': books,
            'source': url,
            'type': 'লাইব্রেরি'
        }
        
        if name:
            doc_id = name.replace('/', '_').replace('.', '').replace(' ', '_')
            library_ref.document(doc_id).set(data)
            count += 1
            
    print(f"Successfully scraped and uploaded {count} libraries.")

if __name__ == '__main__':
    scrape_libraries()
