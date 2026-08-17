import firebase_admin
from firebase_admin import credentials, firestore
import requests
from bs4 import BeautifulSoup
import os
import re

def parse_fire_stations():
    url = "https://fireservice.barisal.gov.bd/pages/static-pages/697895c935ce18e1c066b9ae"
    headers = {'User-Agent': 'Mozilla/5.0'}
    response = requests.get(url, headers=headers, verify=True)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    tables = soup.find_all('table')
    if not tables:
        print("No table found!")
        return []
        
    table = tables[0]
    
    data = []
    current_district = "বরিশাল" # Default fallback
    
    for row in table.find_all('tr'):
        cells = [c.get_text(strip=True) for c in row.find_all(['td', 'th'])]
        
        # Skip header or empty rows
        if not cells or "স্টেশনের নাম" in cells[1] if len(cells) > 1 else False:
            continue
            
        # Typical row with District:
        # [0] = Sl
        # [1] = Station Name
        # [2] = District
        # [3] = Old Number
        # [4] = New Number
        
        # Row without District (because of rowspan):
        # [0] = Sl
        # [1] = Station Name
        # [2] = Old Number
        # [3] = New Number
        
        # Let's check if cells[0] is a number (Sl no) to confirm it's a data row
        sl = cells[0]
        if not any(char.isdigit() or char in '০১২৩৪৫৬৭৮৯' for char in sl):
            continue
            
        if len(cells) >= 5:
            station_name = cells[1]
            current_district = cells[2]
            mobile1 = cells[3]
            mobile2 = cells[4]
        elif len(cells) == 4:
            station_name = cells[1]
            mobile1 = cells[2]
            mobile2 = cells[3]
        else:
            continue
            
        # Clean up mobile numbers (replace non-breaking spaces or hyphens)
        mobile1 = mobile1.replace('--', '').replace('---', '').replace('----', '').strip()
        mobile2 = mobile2.replace('--', '').replace('---', '').replace('----', '').strip()
        
        # If mobile1 is empty, swap
        if not mobile1 and mobile2:
            mobile1 = mobile2
            mobile2 = ""
            
        item = {
            "name": station_name,
            "type": "ফায়ার সার্ভিস",
            "district": current_district,
            "address": current_district,
            "mobile": mobile1,
            "mobile2": mobile2
        }
        data.append(item)
        
    return data

def upload_to_firestore(data):
    try:
        cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
        firebase_admin.initialize_app(cred)
    except ValueError:
        pass
        
    db = firestore.client()
    collection_ref = db.collection('categories').document('fire_service').collection('items')
    
    for item in data:
        # Check if already exists
        existing = collection_ref.where('name', '==', item['name']).get()
        if existing:
            doc_id = existing[0].id
            collection_ref.document(doc_id).set(item, merge=True)
            print(f"Updated: {item['name']}")
        else:
            collection_ref.add(item)
            print(f"Added: {item['name']}")

if __name__ == "__main__":
    print("Scraping Fire Stations...")
    data = parse_fire_stations()
    print(f"Found {len(data)} fire stations.")
    if data:
        upload_to_firestore(data)
        print("Upload complete!")
