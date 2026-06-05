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

def fix_school_data():
    categories = ['primarySchool', 'highSchool', 'college', 'university', 'madrasa']
    
    count_fixed = 0
    for cat in categories:
        docs = db.collection('categories').document(cat).collection('items').stream()
        for doc in docs:
            data = doc.to_dict()
            mobile = str(data.get('mobile', '')).strip()
            headmaster = str(data.get('headmaster', '')).strip()
            address = str(data.get('address', '')).strip()
            
            needs_update = False
            
            # Check if mobile has digits
            has_digits = bool(re.search(r'[0-9০-৯]', mobile))
            
            if mobile and not has_digits:
                # If mobile is actually a designation or name
                if 'অধ্যক্ষ' in mobile or 'প্রধান' in mobile or 'মোঃ' in mobile or 'জনাব' in mobile:
                    # If headmaster is currently empty or looks like an address
                    if not headmaster or 'বারহাজার' in headmaster or 'উপজেলা' in headmaster:
                        if headmaster and not address:
                            address = headmaster
                        headmaster = mobile
                mobile = ''
                needs_update = True
                
            # If headmaster looks like an address
            address_keywords = ['বারহাজার', 'আগৈলঝাড়া', 'গৌরনদী', 'উজিরপুর', 'বানারীপাড়া', 'বাকেরগঞ্জ', 'বাবুগঞ্জ', 'মুলাদী', 'হিজলা', 'মেহেন্দিগঞ্জ', 'সদর', 'উপজেলা', 'গ্রাম', 'ওয়ার্ড']
            if headmaster and any(kw == headmaster for kw in address_keywords):
                if not address:
                    address = headmaster
                headmaster = ''
                needs_update = True
                
            # Specific fixes
            if headmaster == 'বারহাজার':
                if not address: address = headmaster
                headmaster = ''
                needs_update = True
                
            if needs_update:
                data['mobile'] = mobile
                data['headmaster'] = headmaster
                data['address'] = address
                db.collection('categories').document(cat).collection('items').document(doc.id).set(data)
                count_fixed += 1
                
    print(f"Successfully fixed {count_fixed} items.")

if __name__ == '__main__':
    fix_school_data()
