import requests
from bs4 import BeautifulSoup
import firebase_admin
from firebase_admin import credentials, firestore
import os
import re

hotel_images = [
    "https://images.unsplash.com/photo-1566073771259-6a8506099945?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1582719508461-905c673771fd?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1542314831-c6a4d14d837e?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1496417263034-38ec4f0b665a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1551882547-ff40c0d51c02?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80",
    "https://images.unsplash.com/photo-1564501049412-61c2a3083791?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"
]

try:
    cred = credentials.Certificate(os.path.join(os.path.dirname(__file__), 'serviceAccountKey.json'))
    firebase_admin.initialize_app(cred)
except ValueError:
    pass

db = firestore.client()

url = "https://vromonguide.com/best-hotels-in-barishal"
r = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
soup = BeautifulSoup(r.content, 'html.parser')

hotels = []
current_hotel = {}

# In WordPress blogs like VromonGuide, hotels are usually in h2 or h3 tags, followed by p tags with info.
headings = soup.find_all(['h2', 'h3'])
for heading in headings:
    text = heading.get_text(strip=True)
    if not text or "বরিশাল" not in text and "হোটেল" not in text:
        # Some heuristics to find hotel headings, usually they start with a number or just have the name
        pass
        
    # Let's extract sibling paragraphs until the next heading
    paragraphs = []
    sibling = heading.find_next_sibling()
    while sibling and sibling.name not in ['h2', 'h3']:
        if sibling.name in ['p', 'ul', 'li']:
            paragraphs.append(sibling.get_text(separator=' ', strip=True))
        sibling = sibling.find_next_sibling()
        
    if paragraphs:
        # Check if it looks like a hotel block (has phone number or address)
        combined_text = "\n".join(paragraphs)
        if 'অবস্থান' in combined_text or 'যোগাযোগ' in combined_text or 'ভাড়া' in combined_text or 'বুকিং' in combined_text:
            
            # Clean up heading
            name = re.sub(r'^[\d০-৯]+\.\s*', '', text)
            name = re.sub(r'^#\s*[\d০-৯]+\s*', '', name)
            
            # Extract fields
            # Parse fields
            raw_text = "\n".join(paragraphs)
            
            # Split at যোগাযোগ
            parts = raw_text.split('যোগাযোগ')
            description = parts[0].strip()
            contact_block = parts[1] if len(parts) > 1 else ""
            
            address = "বরিশাল সদর"
            mobile = ""
            email = ""
            
            if contact_block:
                # address is from start to মোবাইল or ফোন or ই-মেইল
                address_match = re.split(r'মোবাইলঃ|ফোনঃ|ই-মেইলঃ|ইমেইলঃ', contact_block)
                if address_match:
                    address = address_match[0].strip()
                
                # find mobile
                mobile_matches = re.findall(r'(?:\+88\s*)?01[3-9]\d{8}(?:,\s*(?:\+88\s*)?01[3-9]\d{8})*', contact_block)
                if mobile_matches:
                    mobile = mobile_matches[0]
                    
                # find email
                email_match = re.search(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', contact_block)
                if email_match:
                    email = email_match.group(0)
            
            price = "আলোচনা সাপেক্ষে"
            for p in paragraphs:
                if 'ভাড়া' in p or 'রুম' in p:
                    # Sometimes price is in a separate paragraph without 'যোগাযোগ'
                    if 'রুম ভাড়া:' in p or 'ভাড়া:' in p:
                        price = p.replace('রুম ভাড়া:', '').replace('ভাড়া:', '').strip()
            
            # Extract table for room rents
            room_rents = []
            siblings = heading.find_next_siblings()
            for sib in siblings:
                if sib.name in ['h2', 'h3']:
                    break
                
                table = None
                if sib.name == 'table':
                    table = sib
                elif sib.find('table'):
                    table = sib.find('table')
                    
                if table:
                    rows = table.find_all('tr')
                    for row in rows:
                        cols = row.find_all(['td', 'th'])
                        if len(cols) >= 2:
                            r_type = cols[0].get_text(strip=True)
                            r_price = cols[1].get_text(strip=True)
                            if "রুমের ধরন" not in r_type and "ভাড়া" not in r_price:
                                room_rents.append({"type": r_type, "price": r_price})
                    break

            hotel_data = {
                "name": name,
                "type": "hotel",
                "address": address if address else "বরিশাল সদর",
                "price_per_night": price if price else "আলোচনা সাপেক্ষে",
                "rating": 4.5,
                "reviews": 100,
                "image_url": hotel_images[len(hotels) % len(hotel_images)],
                "mobile": mobile,
                "email": email,
                "amenities": ["Wi-Fi", "AC", "24/7 Service"],
                "room_rents": room_rents,
                "description": description
            }
            hotels.append(hotel_data)

if hotels:
    # Clear existing dummy hotels if any
    collection_ref = db.collection('categories').document('hotel').collection('items')
    existing = collection_ref.get()
    for doc in existing:
        doc.reference.delete()
        
    # Add new hotels
    for hotel in hotels[:8]: # Just to be sure it's the 8 hotels
        collection_ref.add(hotel)
        
    print(f"Successfully scraped and added {min(len(hotels), 8)} hotels from VromonGuide!")
else:
    print("Could not find hotel data in the expected format. Please check the website HTML structure.")
