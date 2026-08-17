import firebase_admin
from firebase_admin import credentials, firestore
import requests
from bs4 import BeautifulSoup
import base64
import os

# Initialize Firebase (assuming serviceAccountKey.json is in the same folder)
cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
try:
    firebase_admin.initialize_app(cred)
except ValueError:
    pass # Already initialized

db = firestore.client()

def normalize_text(text):
    # Replace precomposed Rha/Yya with base char to normalize
    # \u09dc is 'ড়', \u09dd is 'ঢ়', \u09bc is Nukta
    return text.replace('\u09dc', '\u09a1').replace('\u09dd', '\u09a2').replace('\u09bc', '').replace(' ', '')

def parse_upazilas():
    url = "https://barisal.gov.bd/pages/static-pages/697887ac35ce18e1c06624aa"
    response = requests.get(url, verify=True)
    soup = BeautifulSoup(response.content, 'html.parser')

    tables = soup.find_all('table')
    for rt in soup.find_all('rt-renderer'):
        encoded = rt.get('encoded-content')
        if encoded:
            try:
                decoded = base64.b64decode(encoded).decode('utf-8')
                soup2 = BeautifulSoup(decoded, 'html.parser')
                tables.extend(soup2.find_all('table'))
            except:
                pass

    if not tables:
        print("No tables found!")
        return []

    # The data is in the first (or only) table
    target_table = tables[0]
    
    upazilas = []
    paurashavas = []
    thanas = []
    unions_map = {}
    
    for row in target_table.find_all('tr'):
        cells = [c.get_text(strip=True) for c in row.find_all(['td', 'th'])]
        if not cells:
            continue
            
        header = cells[0]
        
        if "খ) উপজেলা" in header and len(cells) > 1:
            upazilas = [u.strip() for u in cells[-1].replace('।', '').split(',')]
            
        elif "গ) থানা" in header and len(cells) > 1:
            thanas = [t.strip() for t in cells[-1].replace('।', '').split(',')]
            
        elif "ঙ) পৌরসভা" in header and len(cells) > 1:
            paurashavas = [p.strip() for p in cells[-1].replace('।', '').split(',')]
            
        else:
            for idx, cell in enumerate(cells[:-1]):
                if "(" in cell and ")" in cell and any(c.isdigit() or c in '০১২৩৪৫৬৭৮৯' for c in cell):
                    upazila_name = cell.split('(')[0].strip()
                    union_list = [u.strip() for u in cells[idx+1].replace('।', '').split(',')]
                    unions_map[upazila_name] = union_list
                    break
    
    print(f"Parsed {len(upazilas)} upazilas")
    
    structured_data = []
    for upazila in upazilas:
        if not upazila:
            continue
            
        u_name = upazila
        
        # Find matching unions
        matched_unions = []
        u_norm = normalize_text(u_name)
        for key in unions_map.keys():
            k_norm = normalize_text(key)
            if u_norm in k_norm or k_norm in u_norm:
                matched_unions = unions_map[key]
                break
                
        # Find matching paurashavas
        matched_paurashavas = []
        for p in paurashavas:
            p_norm = normalize_text(p)
            if p_norm in u_norm or u_norm in p_norm:
                matched_paurashavas.append(p + " পৌরসভা")
                
        # Find matching thanas
        matched_thanas = []
        for t in thanas:
            t_norm = normalize_text(t)
            if u_norm in t_norm:
                matched_thanas.append(t)
                
        if u_name == "বরিশাল সদর":
            # Add Metropolitan Thanas manually as per user requirement to put them under Barishal Sadar
            matched_thanas.extend(["কোতয়ালী থানা", "বিমানবন্দর থানা", "কাউনিয়া থানা"])
            # কাজিরহাট থানা is in Mehendiganj
        elif u_name == "মেহেন্দিগঞ্জ":
            matched_thanas.append("কাজিরহাট থানা")
            
        # Ensure at least one thana if it missed string matching
        if not matched_thanas:
            matched_thanas.append(u_name + " থানা")
            
        structured_data.append({
            "name": u_name,
            "type": "উপজেলা",
            "thanas": matched_thanas,
            "paurashavas": matched_paurashavas,
            "unions": matched_unions,
            # Placeholder values for UI
            "address": "বরিশাল জেলা",
        })
        
    return structured_data

def upload_to_firestore(data):
    collection_ref = db.collection('categories').document('police').collection('items')
    
    # Optional: Delete existing upazilas first?
    # For now, just add them.
    for item in data:
        # Check if already exists by name to avoid duplicates
        existing = collection_ref.where('name', '==', item['name']).get()
        if existing:
            doc_id = existing[0].id
            collection_ref.document(doc_id).set(item, merge=True)
            print(f"Updated: {item['name']}")
        else:
            collection_ref.add(item)
            print(f"Added: {item['name']}")

if __name__ == "__main__":
    print("Scraping upazilas...")
    data = parse_upazilas()
    print(f"Found {len(data)} upazilas to upload.")
    if data:
        upload_to_firestore(data)
        print("Done!")
