import requests
from bs4 import BeautifulSoup
import re
import firebase_admin
from firebase_admin import credentials, firestore

def scrape():
    url = "https://www.findoutdoctor.com/2016/08/best-hospital-clinic-in-barisal.html"
    response = requests.get(url)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    post_body = soup.find(id='post-body')
    if not post_body:
        print("Could not find post-body")
        return
        
    divs = post_body.find_all('div', style=re.compile(r'text-align:\s*center', re.I))
    
    entries = []
    current_entry = []
    
    for div in divs:
        text = div.get_text(strip=True)
        if not text and current_entry:
            entries.append(current_entry)
            current_entry = []
        elif text:
            current_entry.append(text)
            
    if current_entry:
        entries.append(current_entry)

    parsed_data = []
    for entry in entries:
        if len(entry) >= 3:
            name = entry[0].replace(u'\xa0', u' ')
            address = entry[1].replace(u'\xa0', u' ')
            phone_str = ' '.join(entry[2:]).replace(u'\xa0', u' ')
            
            # Extract phone numbers
            phones = re.findall(r'[\d\-+]+', phone_str)
            valid_phones = [p for p in phones if len(p.replace('-', '')) >= 6]
            
            # Remove duplicate phones
            unique_phones = []
            for p in valid_phones:
                if p not in unique_phones:
                    unique_phones.append(p)
            
            if 'Tel:' in phone_str or 'Phone:' in phone_str or 'Hotline' in phone_str or unique_phones:
                parsed_data.append({
                    'name': name,
                    'address': address,
                    'phone1': unique_phones[0] if len(unique_phones) > 0 else '',
                    'phone2': unique_phones[1] if len(unique_phones) > 1 else ''
                })
            
    print(f"Parsed {len(parsed_data)} hospitals/clinics")
    
    # Init firebase
    if not firebase_admin._apps:
        cred = credentials.Certificate('serviceAccountKey.json')
        firebase_admin.initialize_app(cred)
        
    db = firestore.client()
    
    batch = db.batch()
    col_ref = db.collection('categories').doc('diagnostic').collection('items')
    
    # Delete existing
    docs = col_ref.get()
    for doc in docs:
        batch.delete(doc.reference)
        
    for data in parsed_data:
        doc_ref = col_ref.document()
        # English to Bengali mapping for names if needed? The user didn't ask for translation, but they said "সুন্দর করে ডাটা গুলো সেভ করে দাও". Let's save as is, we have AutoTranslatedText in the UI!
        batch.set(doc_ref, data)
        
    batch.commit()
    print("Saved to Firestore successfully!")

if __name__ == "__main__":
    scrape()
