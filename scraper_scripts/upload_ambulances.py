import requests
from bs4 import BeautifulSoup
import json
import re
import firebase_admin
from firebase_admin import credentials, firestore
import os

def scrape_ambulances():
    url = "https://ambu-list.com/barisal-ambulance-service"
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
    }
    
    response = requests.get(url, headers=headers, verify=False)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    text = soup.get_text(separator='\n')
    
    ambulances = []
    
    # Process line by line
    lines = text.split('\n')
    for line in lines:
        line = line.strip()
        if not line:
            continue
            
        # Look for a phone number in the line: 01xxxxxxxxx (11 digits usually, sometimes 10)
        phone_match = re.search(r'(01\d{8,9})', line)
        if phone_match:
            phone = phone_match.group(1)
            # Remove phone from line to get the name
            name_part = line.replace(phone, '').strip(' :,-|()')
            if not name_part:
                name_part = "অজ্ঞাত এম্বুলেন্স"
                
            # If the name part contains the word "Ambulance", it's probably valid
            # Or if it's just some text before the phone number
            # Let's clean it up
            name = name_part
            
            # Simple heuristic for driver name
            driver_name = ""
            if "Azizul Islam" in name:
                driver_name = "Azizul Islam"
                name = name.replace("(Azizul Islam)", "").strip()
            elif "Hassan" in name:
                driver_name = "Hassan"
                name = name.replace("(Hassan)", "").strip()
            elif "Shopongazi" in name:
                driver_name = "Shopongazi"
                name = name.replace("(Shopongazi)", "").strip()
                
            ambulances.append({
                "name": name,
                "type": "এম্বুলেন্স",
                "mobile": phone,
                "driver_name": driver_name,
                "address": "বরিশাল"
            })
            
    # Deduplicate by phone
    unique_ambs = {}
    for a in ambulances:
        # Avoid generic sentences that happen to have a number
        if len(a['name']) < 60:
            unique_ambs[a['mobile']] = a
        
    return list(unique_ambs.values())

def upload_to_firestore(data):
    try:
        cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
        firebase_admin.initialize_app(cred)
    except ValueError:
        pass # Already initialized
        
    db = firestore.client()
    collection_ref = db.collection('categories').document('ambulance').collection('items')
    
    for item in data:
        # Check if already exists
        existing = collection_ref.where('mobile', '==', item['mobile']).get()
        if existing:
            doc_id = existing[0].id
            collection_ref.document(doc_id).set(item, merge=True)
            print(f"Updated: {item['name']} ({item['mobile']})")
        else:
            collection_ref.add(item)
            print(f"Added: {item['name']} ({item['mobile']})")

if __name__ == "__main__":
    print("Scraping Ambulances...")
    data = scrape_ambulances()
    print(f"Found {len(data)} unique ambulances.")
    for d in data:
        print(d)
        
    if data:
        upload_to_firestore(data)
        print("Upload complete!")
